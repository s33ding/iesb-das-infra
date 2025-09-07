variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
}
