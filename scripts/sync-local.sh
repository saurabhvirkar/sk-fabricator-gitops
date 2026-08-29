#!/usr/bin/env bash
# ==============================================================================
# Local GitOps Sync & Validation Script for sk-gitops-manifests Repository
# Allows testing Helm rendering & local kubectl deployment without pushing to remote Git
# ==============================================================================

set -euo pipefail

# Ensure script is executed from repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

echo "=== [GitOps Local Test] Rendering & Deploying Full Stack Dev Environment ==="

# 1. Test Helm Charts Rendering
echo "[1/5] Linting PostgreSQL Helm Chart..."
helm lint helm/postgres

echo "[2/5] Linting Backend Helm Chart..."
helm lint helm/backend

echo "[3/5] Linting Frontend Helm Chart..."
helm lint helm/frontend

# 2. Deploy PostgreSQL Database first
echo "[4/5] Deploying PostgreSQL Database to Local K8s Cluster..."
helm upgrade --install postgres-db helm/postgres

# 3. Deploy Backend & Frontend Microservices
echo "[5/5] Deploying Backend & Frontend to Local K8s Cluster..."
helm upgrade --install backend-api helm/backend -f environments/dev/backend-values.yaml
helm upgrade --install frontend-ui helm/frontend -f environments/dev/frontend-values.yaml

echo -e "\n[✓] Full Stack Local Deployment Complete! Status of Pods:"
kubectl get pods


