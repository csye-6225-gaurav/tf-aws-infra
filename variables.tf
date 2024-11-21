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

variable "zone_id" {
  description = "The Route 53 Hosted Zone ID"
  type        = string
}

variable "domain" {
  type    = string
  default = "gauravgunjal.me"
}

variable "ssh_key_nmae" {
  type = string
}

variable "autoscaling_policy_adjustment_type" {
  type    = string
  default = "ChangeInCapacity"
}

variable "policy_cooldown" {
  type    = number
  default = 120
}

variable "scaling_metric" {
  type    = string
  default = "CPUUtilization"
}

variable "metric_statistics" {
  type    = string
  default = "Average"
}

variable "metric_period" {
  type    = string
  default = "60"
}

variable "treat_missing_data_as" {
  type    = string
  default = "notBreaching"
}

variable "datapoints_to_alarm" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type = number
}

variable "asg_min_size" {
  type = number
}

variable "evaluation_periods" {
  type = string
}

variable "cloudwatch_metric_namespace" {
  type    = string
  default = "AWS/EC2"
}

variable "scale_up_treshold" {
  type = string
}

variable "scale_down_treshold" {
  type = string
}

variable "tg_protocol" {
  type    = string
  default = "HTTP"
}

variable "tg_healthy_treshold" {
  type = number
}
variable "tg_unhealthy_treshold" {
  type = number
}

variable "asg_default_cooldown" {
  type = number
}

variable "lambda_zip" {
  type    = string
  default = "./myFunction.zip"
}

variable "lambda_func_name" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "sendgrid_api_key" {
  type      = string
  sensitive = true
}

variable "lambda_runtime" {
  type    = string
  default = "provided.al2"
}

variable "sns_topic_name" {
  type    = string
  default = "user-verification-topic"
}