output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_ca_certificate
}

output "students_credentials_secret_name" {
  description = "AWS Secrets Manager secret name containing student credentials"
  value       = aws_secretsmanager_secret.students_credentials.name
}

output "ecr_prod_repository_url" {
  description = "URL of the production ECR repository"
  value       = aws_ecr_repository.app_prod.repository_url
}
