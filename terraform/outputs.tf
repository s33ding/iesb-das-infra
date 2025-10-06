output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.development-vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.dev-subnet-1.id, aws_subnet.dev-subnet-2.id]
}

output "ide_password" {
  description = "IDE password (sensitive)"
  value       = random_password.ide_password.result
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.development_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.development_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.development_cluster.certificate_authority[0].data
}
