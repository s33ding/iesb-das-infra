#!/bin/bash

# Connect to EKS cluster
aws eks update-kubeconfig --region us-east-1 --name development-cluster

# Deploy namespace first
kubectl apply -f namespace.yaml

# Apply RBAC configuration
kubectl apply -f rbac.yaml

# Deploy secret provider
kubectl apply -f secret-provider.yaml

# Deploy IDE
kubectl apply -f ide-secure.yaml

# Deploy load balancer
kubectl apply -f ads-lb.yaml

# Wait for deployment
kubectl rollout status deployment/ide-deployment -n ads-system

echo "ADS system deployed to ads-system namespace with domain ads.dataiesb.com"
