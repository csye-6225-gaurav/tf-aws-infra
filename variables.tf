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
  type = number
}

variable "volume_type" {
  description = "Volume type of the webapp instance"
  type = string
}