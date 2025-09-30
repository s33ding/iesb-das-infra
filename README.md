# IESB Development Analysis System Infrastructure

Infrastructure as Code for the Development Analysis System course at IESB University.

## Architecture

- **VPC**: Custom 10.0.0.0/16 network with public subnets
- **EKS**: Managed Kubernetes cluster (v1.30) 
- **IDE**: Cloud-based development environment
- **DNS**: ads.dataiesb.com domain configuration

## Folder Structure

```
├── terraform/          # Infrastructure as Code
│   ├── modules/        # Reusable Terraform modules
│   │   ├── vpc/       # VPC module
│   │   └── eks/       # EKS module
│   ├── policies/      # IAM and security policies
│   └── *.tf          # Main Terraform configuration
├── kubernetes/        # Kubernetes deployments
│   └── ide-deployment/ # IDE container deployment
├── scripts/          # Utility scripts
└── docs/            # Documentation
```

## Components

### Infrastructure (Terraform)
- EKS cluster with node groups
- VPC with Internet Gateway and routing
- Security groups and IAM roles
- ACM certificate for HTTPS

### IDE Deployment (Kubernetes)
- Code Server with development tools
- 50GB GP3 EBS persistent storage
- Docker, kubectl, AWS CLI, eksctl
- Load balancer with public access

## Quick Start

1. **Deploy Infrastructure**:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

2. **Deploy IDE**:
   ```bash
   cd kubernetes/ide-deployment
   kubectl apply -f .
   ```

3. **Access IDE**: https://ads.dataiesb.com

## Management

- **Update secrets**: `./kubernetes/ide-deployment/update-secret.sh`
- **Get password**: Stored in AWS Secrets Manager `ide-password`
- **Kubectl context**: Pre-configured for `default` namespace

## Course Context

This infrastructure supports the Development Analysis System course, providing students with a cloud-based development environment for data analysis and system development projects.
