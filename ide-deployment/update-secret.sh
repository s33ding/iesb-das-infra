#!/bin/bash
# Update IDE secret from AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id ide-password --query SecretString --output text | jq -r .password | kubectl create secret generic ide-secret --from-file=password=/dev/stdin -n ads-system --dry-run=client -o yaml | kubectl apply -f -
echo "Secret updated from AWS Secrets Manager"
