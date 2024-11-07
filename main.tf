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

resource "aws_vpc_security_group_ingress_rule" "allow_lb_traffic" {
  security_group_id            = aws_security_group.app_sec_grp.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.lb_sec_grp.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.app_sec_grp.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = var.sec_grp_cidr
}


resource "aws_vpc_security_group_egress_rule" "allow_all_out_web" {
  security_group_id = aws_security_group.app_sec_grp.id
  cidr_ipv4         = var.sec_grp_cidr
  ip_protocol       = "-1"
}
resource "aws_iam_role" "ec2_s3_access" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

# Create an IAM policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name = "s3_access_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${random_uuid.bucket_name.result}",
          "arn:aws:s3:::${random_uuid.bucket_name.result}/*"
        ]
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "attach_cloudwatch_policy" {
  name       = "attach-cloudwatch-agent-policy"
  roles      = [aws_iam_role.ec2_s3_access.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_s3_access_attach" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
resource "aws_iam_instance_profile" "ec2_s3_access_profile" {
  name = "ec2_s3_access_profile"
  role = aws_iam_role.ec2_s3_access.name
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

resource "aws_route53_record" "app_record" {
  zone_id = var.zone_id
  name    = "${var.env}.${var.domain}"
  type    = "A"
  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

resource "random_uuid" "bucket_name" {}

resource "aws_s3_bucket" "webapp_bucket" {
  bucket = random_uuid.bucket_name.result
  # Force Terraform to delete non-empty bucket by enabling bucket versioning (required by Terraform)
  force_destroy = true

}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.webapp_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycly_policy" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    id = "Transition after 30 days"

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_security_group" "lb_sec_grp" {
  vpc_id = aws_vpc.infra_vpc.id
  name   = "${var.env}-lb security group"
}

resource "aws_vpc_security_group_ingress_rule" "allow_internet_traffic" {
  security_group_id = aws_security_group.lb_sec_grp.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "TCP"
  cidr_ipv4         = var.sec_grp_cidr
}

resource "aws_vpc_security_group_egress_rule" "allow_all_out_lb" {
  security_group_id = aws_security_group.lb_sec_grp.id
  cidr_ipv4         = var.sec_grp_cidr
  ip_protocol       = "-1"
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sec_grp.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  enable_deletion_protection = false
  tags = {
    Environment = "${var.env}"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "lb-tg"
  port     = var.app_port
  protocol = var.tg_protocol
  vpc_id   = aws_vpc.infra_vpc.id
  health_check {
    path                = "/healthz"
    protocol            = var.tg_protocol
    healthy_threshold   = var.tg_healthy_treshold
    unhealthy_threshold = var.tg_unhealthy_treshold
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = var.tg_protocol


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}


resource "aws_launch_template" "webapp_launch_template" {
  name          = "csye6225_asg_template"
  image_id      = var.AMI_id
  instance_type = var.webapp_instance_type
  key_name      = "Aws_key"
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = var.delete_on_termination
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sec_grp.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_access_profile.name
  }
  disable_api_termination = var.ec2_termination_protection

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    echo > /usr/bin/.env
    echo DB_Host=${aws_db_instance.csye6225_rds.address} >> /usr/bin/.env
    echo DB_User=${var.db_user} >> /usr/bin/.env
    echo DB_Pass=${var.db_password} >> /usr/bin/.env
    echo DB_Name=${var.db_name} >> /usr/bin/.env
    echo DB_Port=${var.db_port} >> /usr/bin/.env
    echo APP_Port=${var.app_port} >> /usr/bin/.env
    echo S3_Bucket=${aws_s3_bucket.webapp_bucket.bucket_domain_name} >> /usr/bin/.env
    echo Bucket_Name=${random_uuid.bucket_name.result} >> /usr/bin/.env
    echo region=${var.region} >> /usr/bin/.env
    echo DB_SSLMode=disable >> /usr/bin/.env
    sudo chown csye6225:csye6225 /usr/bin/.env
    sudo chmod 644 /usr/bin/.env
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/cloudwatch-config.json \
    -s
    sudo systemctl restart amazon-cloudwatch-agent
    touch opt/webapp.flag
    sudo systemctl restart webapp.service
  EOF
  )
  depends_on = [aws_db_instance.csye6225_rds]

}

resource "aws_autoscaling_group" "webapp_asg" {
  vpc_zone_identifier = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id, aws_subnet.public_subnet[2].id]
  desired_capacity    = var.asg_min_size
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  default_cooldown    = var.asg_default_cooldown
  launch_template {
    id = aws_launch_template.webapp_launch_template.id
  }
  target_group_arns = [aws_lb_target_group.lb_target_group.id]
  tag {
    key                 = "name"
    propagate_at_launch = true
    value               = "csye6225_asg"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "test_scale_up"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = var.autoscaling_policy_adjustment_type
  scaling_adjustment     = 1
  cooldown               = var.policy_cooldown

}
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "test_scale_down"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = var.autoscaling_policy_adjustment_type
  scaling_adjustment     = -1
  cooldown               = var.policy_cooldown
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "test_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = var.cloudwatch_metric_namespace
  metric_name         = var.scaling_metric
  threshold           = var.scale_down_treshold
  evaluation_periods  = var.evaluation_periods
  period              = var.metric_period
  statistic           = var.metric_statistics
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = var.treat_missing_data_as
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

}
resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  alarm_name          = "test_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = var.cloudwatch_metric_namespace
  metric_name         = var.scaling_metric
  threshold           = var.scale_up_treshold
  evaluation_periods  = var.evaluation_periods
  period              = var.metric_period
  statistic           = var.metric_statistics
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = var.treat_missing_data_as

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

}