# IESB Development Analysis System Infrastructure

Infrastructure as Code for the Development Analysis System course at IESB University.

## Architecture

```mermaid
graph TB
    User[👤 Students] --> ADS[🌐 ads.dataiesb.com]
    ADS --> IDE[💻 IDE Pod<br/>Code Server + kubectl<br/>Pre-configured for EKS]
    
    subgraph EKS[EKS Cluster - Training Environment]
        IDE
        PROD[🚀 Production Apps<br/>Deployed by Students]
    end
    
    IDE -.->|kubectl deploy| PROD
    
    classDef user fill:#4caf50,stroke:#fff,stroke-width:2px,color:#fff
    classDef ide fill:#326ce5,stroke:#fff,stroke-width:2px,color:#fff
    classDef prod fill:#ff9900,stroke:#fff,stroke-width:2px,color:#fff
    
    class User user
    class IDE ide
    class PROD prod
```

### AWS Infrastructure Details

```mermaid
graph TB
    subgraph "Internet"
        User[👤 Students]
        DNS[🌐 ads.dataiesb.com]
    end

    DOCKERFILE[Dockerfile<br/>Code Server + kubectl]

    subgraph "AWS Cloud"
        subgraph "Route 53"
            R53[Route 53<br/>DNS Management]
        end

        subgraph "VPC (10.0.0.0/16)"
            subgraph "Public Subnets"
                IGW[Internet Gateway]
                ALB[Application Load Balancer]
            end

            subgraph "EKS Cluster (v1.30)"
                subgraph "Worker Nodes"
                    subgraph "Namespace: ide"
                        IDE[Code Server IDE<br/>Development Environment]
                        PVC[Persistent Volume<br/>50GB GP3 EBS]
                    end

                    subgraph "System Components"
                        CSI[Secrets Store CSI Driver]
                        ALBC[AWS Load Balancer Controller<br/>Manages ALB]
                    end
                end
            end
        end

        subgraph "AWS Services"
            ECR[Elastic Container Registry<br/>IDE Images]
            SM[Secrets Manager<br/>IDE Password]
            IAM[IAM Roles & Policies<br/>IRSA/OIDC]
        end
    end

    User --> DNS
    DNS --> R53
    R53 --> ALB
    ALB --> IDE
    ACM --> ALB
    IGW --> ALB
    IDE --> PVC
    IDE --> CSI
    CSI --> SM
    ALBC -.->|manages| ALB
    ECR --> IDE
    IAM --> EKS
    IAM --> IDE
    DOCKERFILE --> ECR

    classDef aws fill:#ff9900,stroke:#232f3e,stroke-width:2px,color:#fff
    classDef k8s fill:#326ce5,stroke:#fff,stroke-width:2px,color:#fff
    classDef user fill:#4caf50,stroke:#fff,stroke-width:2px,color:#fff
    classDef build fill:#9c27b0,stroke:#fff,stroke-width:2px,color:#fff

    class R53,ACM,ECR,SM,IAM,IGW,ALB aws
    class EKS,IDE,CSI,ALBC,PVC k8s
    class User,DNS user
    class DOCKERFILE build
```

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
└── docs/            # Documentation
```

## Components

### Infrastructure (Terraform)
- EKS cluster with node groups
- VPC with Internet Gateway and routing
- Security groups and IAM roles
- Route 53 DNS configuration

### IDE Deployment (Kubernetes)
- Code Server with development tools
- 50GB GP3 EBS persistent storage
- Docker, kubectl, AWS CLI, eksctl
- Load balancer with public access
- Secrets Store CSI Driver for AWS Secrets Manager integration

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

3. **Access IDE**: http://ads.dataiesb.com

## Management

- **Update secrets**: `./kubernetes/ide-deployment/update-secret.sh`
- **Get password**: Stored in AWS Secrets Manager `ide-password`
- **Kubectl context**: Pre-configured for `default` namespace

### Secrets Store CSI Driver

The deployment uses the AWS Secrets Store CSI Driver to securely retrieve the IDE password from AWS Secrets Manager. The CSI driver configuration is included in the Kubernetes manifests:

- `14-secrets-store-csi.yaml`: SecretProviderClass configuration
- Automatically syncs secrets from AWS Secrets Manager to Kubernetes secrets
- IDE deployment mounts secrets via CSI volume and environment variables

## Course Context

This infrastructure supports the Development Analysis System course, providing students with a cloud-based development environment for data analysis and system development projects.
