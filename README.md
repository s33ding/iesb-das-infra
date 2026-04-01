# iesb-das-infra

Infraestrutura do sistema ADS (Analysis & Development System) do IESB, rodando no cluster EKS `dataiesb-cluster` em `us-east-1`.

O projeto fornece uma IDE cloud (Code Server) para que alunos e desenvolvedores trabalhem com Kubernetes, AWS e Docker diretamente do navegador, sem precisar configurar nada localmente.

## Arquitetura

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

- Tudo roda no namespace `ads-system` em nodes spot `t3.medium`
- Pods são isolados entre si via NetworkPolicy — bayarea não consegue acessar a IDE
- A IDE tem acesso ao API server do Kubernetes e AWS APIs
- Bay Area roda hardened: read-only, non-root, sem capabilities, sem egress

## Estrutura

```
kubernetes/
├── cluster/
│   └── ads-spot-nodegroup.yaml       # Node group spot (t3.medium, dedicado)
├── network/
│   ├── network-policy.yaml           # Isolamento de rede do namespace
│   └── README.md                     # Documentação de segurança
└── ide-deployment/
    ├── cognito-admin/                # App Streamlit para gerenciar usuários
    │   ├── cognito_admin.py
    │   ├── create-user.sh
    │   ├── policy.json
    │   └── README.md
    ├── Dockerfile                    # Imagem Code Server + ferramentas
    ├── namespace.yaml                # Namespace ads-system
    ├── storage.yaml                  # StorageClass GP3 + PVC 50Gi
    ├── rbac.yaml                     # ServiceAccount com acesso restrito
    ├── deployment.yaml               # IDE deployment
    ├── service.yaml                  # ClusterIP service
    ├── ingress.yaml                  # Ingress ads.dataiesb.com (Cognito)
    ├── bayarea-app.yaml              # App + Ingress bayarea.dataiesb.com
    ├── deploy.py                     # Orquestrador de deploy completo
    ├── setup-aws.py                  # Auto-configura Route53 + WAF
    ├── build-and-push.sh             # Build Docker + push ECR
    └── USER-GUIDE.md                 # Guia do usuário da IDE
```

## Deploy Completo

### Pré-requisitos

- `eksctl`, `kubectl` e AWS CLI configurados
- Python 3 com `boto3`
- VPC CNI com NetworkPolicy habilitado

### 1. Criar o node group

```bash
eksctl create nodegroup -f kubernetes/cluster/ads-spot-nodegroup.yaml
```

### 2. Build e push da imagem

```bash
cd kubernetes/ide-deployment
./build-and-push.sh
```

### 3. Deploy

```bash
cd kubernetes/ide-deployment
python3 deploy.py
```

Isso aplica todos os manifests, aguarda os rollouts e configura Route53 + WAF automaticamente.

## Segurança

| Camada | Descrição |
|---|---|
| Autenticação | Cognito (ads.dataiesb.com) |
| WAF | Rate limiting + regras AWS managed (SQLi, XSS) |
| NetworkPolicy | Deny-all padrão, permite apenas ALB → pods |
| RBAC | Namespace-scoped, sem acesso a Ingress ou outros namespaces |
| Container hardening | Bay Area: non-root, read-only, sem capabilities |

## Gerenciamento de Usuários

O app `cognito-admin` roda localmente e gerencia o whitelist do Cognito:

```bash
cd kubernetes/ide-deployment/cognito-admin
./create-user.sh    # Cria IAM user + salva credenciais
streamlit run cognito_admin.py
```

Ver `cognito-admin/README.md` para detalhes.

## Documentação

- [Guia do Usuário da IDE](kubernetes/ide-deployment/USER-GUIDE.md) — para os usuários da IDE
- [Segurança de Rede](kubernetes/network/README.md) — políticas de rede e matriz de segurança
- [Cognito Admin](kubernetes/ide-deployment/cognito-admin/README.md) — gerenciamento de usuários
