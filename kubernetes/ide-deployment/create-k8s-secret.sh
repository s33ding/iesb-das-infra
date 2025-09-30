#!/bin/bash
# Get password from AWS Secrets Manager and create K8s secret
PASSWORD=$(aws secretsmanager get-secret-value --secret-id ide-password --query SecretString --output text | jq -r .password)
kubectl create secret generic ide-password --from-literal=password="$PASSWORD" -n ads-system --dry-run=client -o yaml | kubectl apply -f -
