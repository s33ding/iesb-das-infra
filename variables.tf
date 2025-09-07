variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "iesb-das"
}

variable "availability_zones_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_instance_types" {
  description = "List of instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "eks_admin_users" {
  description = "List of IAM users to grant admin access to EKS cluster"
  type        = list(string)
  default     = ["students-prof-francisco", "prof-francisco"]
}
