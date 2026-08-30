#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== SK Fabricator & Erector — GitOps Cluster Bootstrap ==="

# 1. Apply Namespaces & Pod Security Standards
echo "1. Applying environment namespaces..."
kubectl apply -f "${REPO_DIR}/bootstrap/namespaces/namespaces.yaml"

# 2. Provision Secrets
echo "2. Provisioning environment secrets..."
"${REPO_DIR}/platform/secrets/create-secrets-dev.sh"
# "${REPO_DIR}/platform/secrets/create-secrets-stage.sh"
# PROD_POSTGRES_PASSWORD="prodpassword123" PROD_JWT_SECRET="ProdSuperSecretKeyForJWTAuth1234567890" "${REPO_DIR}/platform/secrets/create-secrets-prod.sh"

# 3. Apply ResourceQuotas & LimitRanges
echo "3. Applying ResourceQuotas & LimitRanges..."
kubectl apply -f "${REPO_DIR}/platform/resource-quotas/resource-quota.yaml" -n sk-fabricator-dev
# kubectl apply -f "${REPO_DIR}/platform/resource-quotas/resource-quota.yaml" -n sk-fabricator-stage
# kubectl apply -f "${REPO_DIR}/platform/resource-quotas/resource-quota.yaml" -n sk-fabricator-prod

# 4. Apply NetworkPolicies
echo "4. Applying zero-trust NetworkPolicies..."
kubectl apply -f "${REPO_DIR}/platform/network-policies/" -n sk-fabricator-dev
# kubectl apply -f "${REPO_DIR}/platform/network-policies/" -n sk-fabricator-stage
# kubectl apply -f "${REPO_DIR}/platform/network-policies/" -n sk-fabricator-prod

# 5. Apply Argo CD AppProjects
echo "5. Applying Argo CD AppProjects..."
kubectl apply -f "${REPO_DIR}/bootstrap/argocd-projects/"

# 6. Apply Root Application
echo "6. Registering Root Argo CD Application..."
kubectl apply -f "${REPO_DIR}/argocd/root-application.yaml"
kubectl apply -f "${REPO_DIR}/platform/ingress/argocd-ingress.yaml"

# Optional: Uncomment below lines to enable stage and prod workloads locally if needed:
# kubectl apply -f "${REPO_DIR}/argocd/stage/"
# kubectl apply -f "${REPO_DIR}/argocd/prod/"

echo "=== Bootstrap Complete! Argo CD is managing dev workload. ==="


