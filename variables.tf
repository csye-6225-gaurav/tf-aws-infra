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