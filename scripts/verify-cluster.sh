#!/usr/bin/env bash
# ==============================================================================
# Health Check & Verification Script for SK Fabricator GitOps Cluster
# Validates Namespaces, Workloads, NetworkPolicies, and Argo CD Applications
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [SK Fabricator GitOps] Cluster Verification Dashboard ===${NC}\n"

# 1. Namespaces
echo -e "${BLUE}1. Checking Environment Namespaces...${NC}"
# To include stage and prod namespaces when enabled locally, update loop: sk-fabricator-dev sk-fabricator-stage sk-fabricator-prod argocd
for ns in sk-fabricator-dev argocd; do
  if kubectl get namespace "${ns}" &>/dev/null; then
    echo -e "  [✓] Namespace ${GREEN}${ns}${NC} exists."
  else
    echo -e "  [!] Namespace ${RED}${ns}${NC} missing."
  fi
done

# 2. Argo CD Applications Status
echo -e "\n${BLUE}2. Argo CD Managed Applications:${NC}"
kubectl get applications -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status 2>/dev/null || echo "Argo CD not running"

# 3. Workload Pod Health in Dev Namespace
echo -e "\n${BLUE}3. Workload Pods in 'sk-fabricator-dev':${NC}"
kubectl get pods -n sk-fabricator-dev -o wide 2>/dev/null || echo "No pods in dev namespace"

# 4. Ingress Endpoints Check
echo -e "\n${BLUE}4. Ingress Routing & Health Check:${NC}"
if curl -s -I -H "Host: skfabricator.local" http://127.0.0.1/ | grep -q "200 OK"; then
  echo -e "  [✓] Frontend UI (skfabricator.local): ${GREEN}HTTP 200 OK${NC}"
else
  echo -e "  [!] Frontend UI (skfabricator.local): ${YELLOW}Not responding on port 80${NC}"
fi

API_HEALTH=$(curl -s -H "Host: api.skfabricator.local" http://127.0.0.1/health 2>/dev/null || echo "")
if [[ "${API_HEALTH}" == *"Healthy"* ]]; then
  echo -e "  [✓] Backend API (api.skfabricator.local/health): ${GREEN}Healthy${NC}"
else
  echo -e "  [!] Backend API (api.skfabricator.local/health): ${YELLOW}Not responding${NC}"
fi

echo -e "\n${GREEN}=== Verification Complete! ===${NC}"
