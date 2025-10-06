# IESB Development Analysis System - Architecture Diagram

## Infrastructure Overview

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

## Repository Structure

```mermaid
graph LR
    subgraph "Repository Structure"
        ROOT[iesb-das-infra/]
        
        subgraph "Infrastructure"
            TF[terraform/]
            TF_MAIN[main.tf<br/>EKS + VPC]
            TF_MOD[modules/<br/>vpc/ + eks/]
            TF_POL[policies/<br/>IAM policies]
            TF_IAM[iam.tf + alb-controller-iam.tf]
        end

        subgraph "Kubernetes"
            K8S[kubernetes/]
            K8S_ALB[01-13: ALB Controller]
            K8S_IDE[ide-deployment/]
            K8S_DEPLOY[deployment.yaml]
            K8S_SVC[service.yaml + ingress.yaml]
        end

        subgraph "DNS & Certificates"
            CF[CloudFormation-Route53-ACM/]
            CF_YAML[route53-acm.yaml]
        end

        subgraph "Utilities"
            SCRIPTS[scripts/]
            DOCS[docs/]
        end
    end

    ROOT --> TF
    ROOT --> K8S
    ROOT --> CF
    ROOT --> SCRIPTS
    ROOT --> DOCS
    
    TF --> TF_MAIN
    TF --> TF_MOD
    TF --> TF_POL
    TF --> TF_IAM
    
    K8S --> K8S_ALB
    K8S --> K8S_IDE
    K8S_IDE --> K8S_DEPLOY
    K8S_IDE --> K8S_SVC
    
    CF --> CF_YAML

    classDef terraform fill:#623ce4,stroke:#fff,stroke-width:2px,color:#fff
    classDef kubernetes fill:#326ce5,stroke:#fff,stroke-width:2px,color:#fff
    classDef cloudformation fill:#ff9900,stroke:#fff,stroke-width:2px,color:#fff
    classDef utils fill:#4caf50,stroke:#fff,stroke-width:2px,color:#fff

    class TF,TF_MAIN,TF_MOD,TF_POL,TF_IAM terraform
    class K8S,K8S_ALB,K8S_IDE,K8S_DEPLOY,K8S_SVC kubernetes
    class CF,CF_YAML cloudformation
    class SCRIPTS,DOCS utils
```

## Deployment Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant CF as CloudFormation
    participant TF as Terraform
    participant K8S as Kubernetes
    participant AWS as AWS Services

    Note over Dev,AWS: Infrastructure Deployment

    Dev->>CF: 1. Deploy Route53 + ACM
    CF->>AWS: Create DNS zone & SSL certificate
    
    Dev->>TF: 2. terraform init & apply
    TF->>AWS: Create VPC, EKS cluster, IAM roles
    AWS-->>TF: Infrastructure ready
    
    Dev->>K8S: 3. Deploy ALB Controller
    K8S->>AWS: Install AWS Load Balancer Controller
    
    Dev->>K8S: 4. Deploy IDE
    K8S->>AWS: Create pods, services, ingress
    AWS-->>K8S: Load balancer provisioned
    
    Note over Dev,AWS: Access Flow
    Dev->>AWS: Access https://ads.dataiesb.com
    AWS->>K8S: Route to IDE service
    K8S-->>Dev: Code Server interface
```

## Key Components

### Infrastructure (Terraform)
- **VPC Module**: Custom 10.0.0.0/16 network with public subnets
- **EKS Module**: Managed Kubernetes cluster v1.30 with node groups
- **IAM**: Service accounts, OIDC provider, ALB controller permissions
- **ECR**: Container registry for IDE images

### Kubernetes Deployments
- **AWS Load Balancer Controller**: Manages ALB for ingress
- **Secrets Store CSI Driver**: Integrates with AWS Secrets Manager
- **IDE Deployment**: Code Server with development tools
- **Persistent Storage**: 50GB GP3 EBS volume for user data

### DNS & Security
- **Route 53**: DNS management for ads.dataiesb.com
- **ACM Certificate**: SSL/TLS encryption
- **Security Groups**: Network access control
- **IAM Roles**: Fine-grained permissions with IRSA

## Access Information
- **URL**: https://ads.dataiesb.com
- **Password**: Stored in AWS Secrets Manager (`ide-password`)
- **Tools**: Docker, kubectl, AWS CLI, eksctl pre-installed
