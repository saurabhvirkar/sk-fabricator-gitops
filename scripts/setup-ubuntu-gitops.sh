#!/usr/bin/env bash
# ==============================================================================
# GitOps Local Environment Setup Script for Ubuntu Operating System
# Installs & Configures: Minikube / K3d, kubectl, Helm 3, NGINX Ingress, ArgoCD
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== [GitOps Engineer] Starting Ubuntu Local Environment Setup ===${NC}\n"

# 1. Check & Install Dependencies
check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${YELLOW}[!] $1 is not installed.${NC}"
    return 1
  else
    echo -e "${GREEN}[✓] $1 is installed: $(command -v $1)${NC}"
    return 0
  fi
}

echo -e "${BLUE}1. Checking required tools...${NC}"
check_tool docker || { echo -e "${RED}Please install Docker on Ubuntu first: sudo apt install docker.io -y${NC}"; exit 1; }
check_tool kubectl || {
  echo -e "${YELLOW}Installing kubectl...${NC}"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
}

check_tool helm || {
  echo -e "${YELLOW}Installing Helm 3...${NC}"
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

check_tool minikube || {
  echo -e "${YELLOW}Installing Minikube...${NC}"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm minikube-linux-amd64
}

# 2. Start Local Kubernetes Cluster
echo -e "\n${BLUE}2. Starting Minikube Kubernetes Cluster...${NC}"
if minikube status | grep -q "Running"; then
  echo -e "${GREEN}[✓] Minikube is already running.${NC}"
else
  minikube start --driver=docker --cpus=2 --memory=4096 --addons=ingress,dashboard
fi

# 3. Install ArgoCD
echo -e "\n${BLUE}3. Installing ArgoCD in Namespace 'argocd'...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


echo -e "${YELLOW}Waiting for ArgoCD server deployment to roll out...${NC}"
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s || true

# 4. Expose ArgoCD Server & Retrieve Admin Credentials
echo -e "\n${BLUE}4. ArgoCD Credentials & Access Information:${NC}"
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "Check argocd secrets")

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}  ArgoCD Local Installation Complete!                ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "Username: ${YELLOW}admin${NC}"
echo -e "Password: ${YELLOW}${ARGOCD_PASS}${NC}"
echo -e "\nTo access ArgoCD UI locally on Ubuntu, run:"
echo -e "  ${BLUE}kubectl port-forward svc/argocd-server -n argocd 8080:443${NC}"
echo -e "Then open: ${YELLOW}https://localhost:8080${NC}\n"

echo -e "${GREEN}[✓] Local GitOps Infrastructure Ready for Deployment!${NC}"
