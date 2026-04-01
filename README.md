# iesb-das-infra

Infrastructure for the IESB ADS (Analysis & Development System), running on the `dataiesb-cluster` EKS cluster in `us-east-1`.

The project provides a cloud IDE (Code Server) so students and developers can work with Kubernetes, AWS, and Docker directly from the browser with zero local setup.

## Architecture

```
Internet
    │
    ├── ads.dataiesb.com ──────► ALB (Cognito + WAF) ──► IDE (Code Server)
    │                                                        ├── kubectl
    │                                                        ├── AWS CLI
    │                                                        └── Docker
    │
    └── bayarea.dataiesb.com ──► ALB ──► Bay Area App (nginx)
```

- Everything runs in the `ads-system` namespace on dedicated spot `t3.medium` nodes
- Pods are isolated from each other via NetworkPolicy — bayarea cannot reach the IDE
- The IDE has access to the Kubernetes API server and AWS APIs
- Bay Area runs hardened: read-only, non-root, no capabilities, no egress

## Structure

```
kubernetes/
├── cluster/
│   └── ads-spot-nodegroup.yaml       # Spot node group (t3.medium, dedicated)
├── network/
│   ├── network-policy.yaml           # Namespace network isolation
│   └── README.md                     # Security documentation
└── ide-deployment/
    ├── cognito-admin/                # Streamlit app for user management
    │   ├── cognito_admin.py
    │   ├── create-user.sh
    │   ├── policy.json
    │   └── README.md
    ├── Dockerfile                    # Code Server image + tools
    ├── namespace.yaml                # ads-system namespace
    ├── storage.yaml                  # GP3 StorageClass + 50Gi PVC
    ├── rbac.yaml                     # ServiceAccount with restricted access
    ├── deployment.yaml               # IDE deployment
    ├── service.yaml                  # ClusterIP service
    ├── ingress.yaml                  # Ingress ads.dataiesb.com (Cognito)
    ├── bayarea-app.yaml              # App + Ingress bayarea.dataiesb.com
    ├── deploy.py                     # Full deployment orchestrator
    ├── setup-aws.py                  # Auto-configures Route53 + WAF
    ├── build-and-push.sh             # Docker build + ECR push
    └── USER-GUIDE.md                 # IDE user guide (Portuguese)
```

## Full Deploy

### Prerequisites

- `eksctl`, `kubectl`, and AWS CLI configured
- Python 3 with `boto3`
- VPC CNI with NetworkPolicy enabled

### 1. Create the node group

```bash
eksctl create nodegroup -f kubernetes/cluster/ads-spot-nodegroup.yaml
```

### 2. Build and push the image

```bash
cd kubernetes/ide-deployment
./build-and-push.sh
```

### 3. Deploy

```bash
cd kubernetes/ide-deployment
python3 deploy.py
```

This applies all manifests, waits for rollouts, and configures Route53 + WAF automatically.

## Security

| Layer | Description |
|---|---|
| Authentication | Cognito (ads.dataiesb.com) |
| WAF | Rate limiting + AWS managed rules (SQLi, XSS) |
| NetworkPolicy | Deny-all default, allows only ALB → pods |
| RBAC | Namespace-scoped, no access to Ingress or other namespaces |
| Container hardening | Bay Area: non-root, read-only, no capabilities |

## User Management

The `cognito-admin` app runs locally and manages the Cognito whitelist:

```bash
cd kubernetes/ide-deployment/cognito-admin
./create-user.sh    # Creates IAM user + stores credentials
streamlit run cognito_admin.py
```

See `cognito-admin/README.md` for details.

## Documentation

- [IDE User Guide](kubernetes/ide-deployment/USER-GUIDE.md) — for IDE users (Portuguese)
- [Network Security](kubernetes/network/README.md) — network policies and security matrix
- [Cognito Admin](kubernetes/ide-deployment/cognito-admin/README.md) — user management
