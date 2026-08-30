#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== SK Fabricator & Erector — GitOps Cluster Bootstrap (Dev) ==="

# 1. Apply Namespaces & Pod Security Standards
echo "1. Applying dev environment namespace..."
kubectl apply -f "${REPO_DIR}/bootstrap/namespaces/namespaces.yaml"

# 2. Provision Secrets
echo "2. Provisioning dev environment secrets..."
"${REPO_DIR}/platform/secrets/create-secrets-dev.sh"

# 3. Apply ResourceQuotas & LimitRanges
echo "3. Applying ResourceQuotas & LimitRanges..."
kubectl apply -f "${REPO_DIR}/platform/resource-quotas/resource-quota.yaml" -n sk-fabricator-dev

# 4. Apply NetworkPolicies
echo "4. Applying zero-trust NetworkPolicies..."
kubectl apply -f "${REPO_DIR}/platform/network-policies/" -n sk-fabricator-dev

# 5. Apply Argo CD AppProjects
echo "5. Applying Argo CD AppProjects..."
kubectl apply -f "${REPO_DIR}/bootstrap/argocd-projects/"

# 6. Apply Root Application
echo "6. Registering Root Argo CD Application..."
kubectl apply -f "${REPO_DIR}/argocd/root-application.yaml"
kubectl apply -f "${REPO_DIR}/platform/ingress/argocd-ingress.yaml"

echo "=== Bootstrap Complete! Argo CD is managing dev workload. ==="

