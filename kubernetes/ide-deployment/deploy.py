#!/usr/bin/env python3
"""Deploy all IDE infrastructure to EKS."""

import subprocess
import sys

REGION = "us-east-1"
CLUSTER = "dataiesb-cluster"

MANIFESTS = [
    "namespace.yaml",
    "../network/network-policy.yaml",
    "storage.yaml",
    "rbac.yaml",
    "deployment.yaml",
    "service.yaml",
    "ingress.yaml",
    "bayarea-app.yaml",
]

DEPLOYMENTS = [
    "ide-deployment",
    "bayarea-app",
]

NAMESPACE = "ads-system"


def run(cmd):
    print(f"  $ {cmd}")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        print(f"FAILED: {cmd}")
        sys.exit(1)


def main():
    print("Updating kubeconfig...")
    run(f"aws eks update-kubeconfig --region {REGION} --name {CLUSTER}")

    print("Applying manifests...")
    for m in MANIFESTS:
        run(f"kubectl apply -f {m}")

    print("Waiting for rollouts...")
    for d in DEPLOYMENTS:
        run(f"kubectl rollout status deployment/{d} -n {NAMESPACE} --timeout=120s")

    print("Configuring Route53 + WAF...")
    run("python3 setup-aws.py")

    print("\nDone!")
    print("  IDE:      https://ads.dataiesb.com")
    print("  Bay Area: https://bayarea.dataiesb.com")


if __name__ == "__main__":
    main()
