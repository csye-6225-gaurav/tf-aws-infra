resource "aws_vpc" "infra_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "infra_igw" {
  vpc_id = aws_vpc.infra_vpc.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-subnet-${count.index + 1}"

  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.infra_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.env}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.infra_vpc.id
  route {
    cidr_block = var.route_cidr_range
    gateway_id = aws_internet_gateway.infra_igw.id
  }
  tags = {
    Name = "${var.env}-public-route-table"
  }
}

resource "aws_route_table_association" "public_rta_assc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.infra_vpc.id
  tags = {
    Name = "${var.env}-private-route-table"
  }
}

resource "aws_route_table_association" "private_rta_assc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "app_sec_grp" {
  vpc_id = aws_vpc.infra_vpc.id
  name   = "${var.env}-application security group"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.app_sec_grp.id
  cidr_ipv4         = var.sec_grp_cidr
  from_port         = tonumber(each.value)
  ip_protocol       = "tcp"
  to_port           = tonumber(each.value)

  for_each = toset([for port in var.ingress_ports : tostring(port)])
}


resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.app_sec_grp.id
  cidr_ipv4         = var.sec_grp_cidr
  ip_protocol       = "-1"
}

resource "aws_instance" "webapp_instance" {
  ami                     = var.AMI_id
  instance_type           = var.webapp_instance_type
  subnet_id               = aws_subnet.public_subnet[0].id
  vpc_security_group_ids  = [aws_security_group.app_sec_grp.id]
  disable_api_termination = var.ec2_termination_protection

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = var.delete_on_termination
  }
  user_data = <<-EOF
    #!/bin/bash
    echo > /usr/bin/.env
    echo DB_Host=${aws_db_instance.csye6225_rds.address} >> /usr/bin/.env
    echo DB_User=${var.db_user} >> /usr/bin/.env
    echo DB_Pass=${var.db_password} >> /usr/bin/.env
    echo DB_Name=${var.db_name} >> /usr/bin/.env
    echo DB_Port=${var.db_port} >> /usr/bin/.env
    echo APP_Port=${var.app_port} >> /usr/bin/.env
    echo DB_SSLMode=disable >> /usr/bin/.env
    sudo chown csye6225:csye6225 /usr/bin/.env
    sudo chmod 644 /usr/bin/.env
    touch opt/webapp.flag
    sudo systemctl restart webapp.service
  EOF

  depends_on = [aws_db_instance.csye6225_rds]
  tags = {
    Name = "${var.env}-webapp-instance"
  }
}

resource "aws_security_group" "db_sec_grp" {
  vpc_id = aws_vpc.infra_vpc.id
  name   = "${var.env}-database security group"
}

resource "aws_vpc_security_group_ingress_rule" "allow_webapp_traffic" {
  security_group_id            = aws_security_group.db_sec_grp.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app_sec_grp.id
}

resource "aws_vpc_security_group_egress_rule" "allow_webapp_traffic_egress" {
  security_group_id            = aws_security_group.db_sec_grp.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app_sec_grp.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "${var.env}-rds-subnet-group"
  }
}

resource "aws_db_instance" "csye6225_rds" {
  engine                 = var.db_engine
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  identifier             = var.db_identifier
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  multi_az               = var.db_multi_az
  publicly_accessible    = var.db_publicly_accessibility
  vpc_security_group_ids = [aws_security_group.db_sec_grp.id]
  skip_final_snapshot    = var.db_skip_final_snapshot
  apply_immediately      = var.db_apply_immediately
  parameter_group_name   = aws_db_parameter_group.postgres_pg.name

  tags = {
    Name = "${var.env}-rds-instance"
  }
}

resource "aws_db_parameter_group" "postgres_pg" {
  name   = "${var.env}-db-pg"
  family = var.parameter_grp_family

  parameter {
    name  = "log_connections"
    value = var.log_db_conections
  }

  parameter {
    name  = "rds.force_ssl"
    value = var.force_ssl
  }
  lifecycle {
    create_before_destroy = true
  }
}