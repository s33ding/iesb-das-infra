# Network & Security — ads-system

## Português

Políticas de rede e segurança para o namespace `ads-system`.

### Políticas de Rede

| Política | Descrição |
|---|---|
| `deny-all` | Bloqueia todo tráfego de entrada e saída por padrão |
| `allow-dns` | Permite resolução DNS para todos os pods |
| `allow-ide-egress` | Permite saída total para o IDE (kubectl, AWS APIs) |
| `allow-alb-to-ide` | Permite entrada do ALB na porta 8080 |
| `allow-alb-to-bayarea` | Permite entrada do ALB na porta 80 |

### Defesa em Camadas

| Camada | IDE | Bayarea |
|---|---|---|
| Entrada | Apenas ALB (porta 8080) | Apenas ALB (porta 80) |
| Saída | Total (precisa de kubectl, AWS) | Bloqueada totalmente |
| Service account | Sim (escopo do namespace) | Nenhuma (token não montado) |
| Sistema de arquivos | Leitura e escrita | Somente leitura |
| Capabilities Linux | Padrão | Todas removidas |
| Escalação de privilégio | Padrão | Bloqueada |
| Executa como | Usuário coder | Non-root (uid 101) |
| Limites de recursos | Nenhum | 100m CPU, 64Mi RAM |

### Pré-requisito

O VPC CNI deve ter suporte a NetworkPolicy habilitado:

```bash
aws eks update-addon --cluster-name dataiesb-cluster --addon-name vpc-cni \
  --configuration-values '{"enableNetworkPolicy": "true"}' --region us-east-1
```

---

## English

Network and security policies for the `ads-system` namespace.

### Network Policies

| Policy | Description |
|---|---|
| `deny-all` | Blocks all ingress and egress by default |
| `allow-dns` | Allows DNS resolution for all pods |
| `allow-ide-egress` | Allows full egress for the IDE (kubectl, AWS APIs) |
| `allow-alb-to-ide` | Allows ALB ingress on port 8080 |
| `allow-alb-to-bayarea` | Allows ALB ingress on port 80 |

### Layered Defense

| Layer | IDE | Bayarea |
|---|---|---|
| Ingress | ALB only (port 8080) | ALB only (port 80) |
| Egress | Full (needs kubectl, AWS) | Blocked entirely |
| Service account | Yes (namespace-scoped) | None (token not mounted) |
| Root filesystem | Read-write | Read-only |
| Linux capabilities | Default | All dropped |
| Privilege escalation | Default | Blocked |
| Runs as | coder user | Non-root (uid 101) |
| Resource limits | None | 100m CPU, 64Mi RAM |

### Prerequisite

VPC CNI must have NetworkPolicy support enabled:

```bash
aws eks update-addon --cluster-name dataiesb-cluster --addon-name vpc-cni \
  --configuration-values '{"enableNetworkPolicy": "true"}' --region us-east-1
```
