#!/usr/bin/env bash
# ==============================================================================
# Local GitOps Sync & Validation Script for sk-gitops-manifests Repository
# Builds local Docker images, loads into Kind, and deploys Helm microservices
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="$(cd "${REPO_ROOT}/.." && pwd)"
cd "${REPO_ROOT}"

echo "=== [GitOps Local Test] Building Images & Deploying Dev Environment ==="

# 1. Lint Helm Charts
echo "[1/6] Linting PostgreSQL Helm Chart..."
helm lint helm/postgres

echo "[2/6] Linting Backend Helm Chart..."
helm lint helm/backend

echo "[3/6] Linting Frontend Helm Chart..."
helm lint helm/frontend

# 2. Build Docker Container Images locally if source directories exist
echo "[4/6] Building local Docker container images..."
if [ -d "${WORKSPACE_ROOT}/SkFabricatorAndErector-Backend" ]; then
  echo "Building skfabricator-backend:latest..."
  docker build -t skfabricator-backend:latest "${WORKSPACE_ROOT}/SkFabricatorAndErector-Backend"
fi

if [ -d "${WORKSPACE_ROOT}/SkFabricatorAndErector-Frontend" ]; then
  echo "Building skfabricator-frontend:latest..."
  docker build -t skfabricator-frontend:latest "${WORKSPACE_ROOT}/SkFabricatorAndErector-Frontend"
fi

# 3. Load Images into Kind Cluster
echo "[5/6] Loading Docker images into Kind cluster ('skops')..."
if command -v kind &> /dev/null && kind get clusters 2>/dev/null | grep -q "^skops$"; then
  kind load docker-image skfabricator-backend:latest --name skops
  kind load docker-image skfabricator-frontend:latest --name skops
fi

# 4. Deploy Microservice Helm Releases
echo "[6/6] Deploying Full Stack (DB + Backend + Frontend) to Kind Cluster..."
helm upgrade --install postgres-db helm/postgres
helm upgrade --install backend-api helm/backend -f environments/dev/backend-values.yaml
helm upgrade --install frontend-ui helm/frontend -f environments/dev/frontend-values.yaml

echo -e "\n[✓] Full Stack Deployment Triggered! Pod Status:"
kubectl get pods
