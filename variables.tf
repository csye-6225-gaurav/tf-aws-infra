variable "env" {
  description = "Environment name, e.g., dev, prod"
  type        = string
}

variable "profile" {
  description = "AWS cli profile name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "route_cidr_range" {
  description = "The CIDR range to route through the Internet Gateway"
  type        = string
}

variable "sec_grp_cidr" {
  type = string
}

variable "ingress_ports" {
  description = "List of ports to allow ingress"
  type        = list(number)
  default     = [22, 80, 443, 8080]
}

variable "egress_ports" {
  description = "ports to allow egress"
  type        = number
  default     = 0
}

variable "AMI_id" {
  description = "AMI id for packer image"
  type        = string
}

variable "webapp_instance_type" {
  description = "Type of instance for the webapp eg:t2.micro"
  type        = string
}

variable "volume_size" {
  description = "Volume size of the webapp instance"
  type        = number
}

variable "volume_type" {
  description = "Volume type of the webapp instance"
  type        = string
}

variable "ec2_termination_protection" {
  description = "Flag to stop ec2 termination protection"
  type        = bool
}
variable "delete_on_termination" {
  description = "Flag to delete EBS volume when instance is terminated"
  type        = bool
}

variable "db_engine" {
  description = "DB engine type eg:postgres or mysql"
  type        = string
}
variable "db_instance_class" {
  description = "Type of instance for db eg:db.t3.micro"
  type        = string
}

variable "db_allocated_storage" {
  description = "Size of the DB instance"
  type        = number
}

variable "db_identifier" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_name" {
  description = "name of the database"
  type        = string
}
variable "db_password" {
  description = "password for the database"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "username for the database"
  type        = string
}

variable "db_port" {
  description = "database port number"
  type        = number
}

variable "app_port" {
  type = number
}

variable "db_publicly_accessibility" {
  type = bool
}

variable "log_db_conections" {
  type    = string
  default = "1"
}

variable "force_ssl" {
  type    = string
  default = "0"
}

variable "parameter_grp_family" {
  type    = string
  default = "postgres16"
}

variable "db_skip_final_snapshot" {
  type = bool
}

variable "db_apply_immediately" {
  type = bool
}