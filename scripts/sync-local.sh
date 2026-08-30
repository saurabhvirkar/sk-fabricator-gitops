#!/usr/bin/env bash
# ==============================================================================
# Local GitOps Sync & Validation Script for sk-fabricator-gitops
# Builds local Docker images, loads into Kind, and deploys dev Helm stack
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="$(cd "${REPO_ROOT}/.." && pwd)"
NAMESPACE="sk-fabricator-dev"

cd "${REPO_ROOT}"

echo "=== [GitOps Local Test] Building Images & Deploying Dev Environment (${NAMESPACE}) ==="

# 1. Lint Helm Charts
echo "[1/6] Linting PostgreSQL Helm Chart..."
helm lint charts/postgres

echo "[2/6] Linting Backend Helm Chart..."
helm lint charts/backend

echo "[3/6] Linting Frontend Helm Chart..."
helm lint charts/frontend

# 2. Build Docker Container Images locally if source directories exist
echo "[4/6] Building local Docker container images..."
if [ -d "${WORKSPACE_ROOT}/SkFabricatorAndErector-Backend" ]; then
  echo "Building ghcr.io/saurabhvirkar/skfabricator-backend:dev-latest..."
  docker build -t ghcr.io/saurabhvirkar/skfabricator-backend:dev-latest "${WORKSPACE_ROOT}/SkFabricatorAndErector-Backend"
fi

if [ -d "${WORKSPACE_ROOT}/SkFabricatorAndErector-Frontend" ]; then
  echo "Building ghcr.io/saurabhvirkar/skfabricator-frontend:dev-latest..."
  docker build -t ghcr.io/saurabhvirkar/skfabricator-frontend:dev-latest "${WORKSPACE_ROOT}/SkFabricatorAndErector-Frontend"
fi

# 3. Load Images into Kind Cluster
echo "[5/6] Loading Docker images into Kind cluster ('skops')..."
if command -v kind &> /dev/null && kind get clusters 2>/dev/null | grep -q "^skops$"; then
  kind load docker-image ghcr.io/saurabhvirkar/skfabricator-backend:dev-latest --name skops
  kind load docker-image ghcr.io/saurabhvirkar/skfabricator-frontend:dev-latest --name skops
fi

# 4. Provision Secrets & Deploy Microservice Helm Releases
echo "[6/6] Provisioning Secrets & Deploying Full Stack to ${NAMESPACE}..."
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
"${SCRIPT_DIR}/../platform/secrets/create-secrets-dev.sh"

helm upgrade --install postgres-db charts/postgres -n "${NAMESPACE}" -f environments/dev/postgres-values.yaml
helm upgrade --install backend-api charts/backend -n "${NAMESPACE}" -f environments/dev/backend-values.yaml
helm upgrade --install frontend-ui charts/frontend -n "${NAMESPACE}" -f environments/dev/frontend-values.yaml

echo -e "\n[✓] Full Stack Deployment Triggered! Pod Status in ${NAMESPACE}:"
kubectl get pods -n "${NAMESPACE}"
