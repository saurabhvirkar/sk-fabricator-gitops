#!/usr/bin/env bash
# ==============================================================================
# GitOps Local Environment Setup Script for Ubuntu using Kind (Kubernetes in Docker)
# Installs & Configures: Kind, kubectl, Helm 3, NGINX Ingress for Kind, ArgoCD
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== [GitOps Engineer] Starting Ubuntu Local Setup with Kind (K8s in Docker) ===${NC}\n"

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

check_tool kind || {
  echo -e "${YELLOW}Installing Kind (Kubernetes in Docker)...${NC}"
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  echo -e "${GREEN}[✓] Kind installed successfully.${NC}"
}

# 2. Start Kind Kubernetes Cluster with Ingress Port Mappings
echo -e "\n${BLUE}2. Starting Kind Kubernetes Cluster ('skops')...${NC}"
if kind get clusters 2>/dev/null | grep -q "^skops$"; then
  echo -e "${GREEN}[✓] Kind cluster 'skops' is already running.${NC}"
else
  cat <<EOF | kind create cluster --name skops --config=-
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    apiVersion: kubeadm.k8s.io/v1beta3
    kind: ClusterConfiguration
    metadata:
      name: config
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
fi

# 3. Deploy NGINX Ingress Controller for Kind
echo -e "\n${BLUE}3. Deploying NGINX Ingress Controller for Kind...${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo -e "${YELLOW}Waiting for NGINX Ingress Controller rollout...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s || true

# 4. Install ArgoCD
echo -e "\n${BLUE}4. Installing ArgoCD in Namespace 'argocd'...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "${YELLOW}Waiting for ArgoCD server deployment to roll out...${NC}"
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s || true

# 5. Expose ArgoCD Server & Retrieve Admin Credentials
echo -e "\n${BLUE}5. ArgoCD Credentials & Access Information:${NC}"
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "Check argocd secrets")

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}  ArgoCD & Kind Cluster Setup Complete!              ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "Cluster Name: ${YELLOW}skops (Kind)${NC}"
echo -e "ArgoCD Username: ${YELLOW}admin${NC}"
echo -e "ArgoCD Password: ${YELLOW}${ARGOCD_PASS}${NC}"
echo -e "\nTo access ArgoCD UI locally on Ubuntu, run:"
echo -e "  ${BLUE}kubectl port-forward svc/argocd-server -n argocd 8080:443${NC}"
echo -e "Then open: ${YELLOW}https://localhost:8080${NC}\n"

echo -e "${GREEN}[✓] Kind Local GitOps Infrastructure Ready!${NC}"
