# Complete Step-by-Step Guide: Running GitOps Stack Locally with Kind (Kubernetes in Docker)

This guide provides basic-to-advanced, copy-paste terminal instructions to install all prerequisites, set up the local **Kind (Kubernetes in Docker)** cluster, connect **Frontend + Backend + PostgreSQL Database**, and manage the entire environment via **ArgoCD GitOps** on Ubuntu OS.

---

## 🛠️ Step 1: Install All Prerequisites on Ubuntu Terminal

Open your Ubuntu terminal and execute the following commands:

### 1.1 Update Package Manager & Install Basics
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git apt-transport-https ca-certificates gnupg lsb-release
```

### 1.2 Install Docker Engine & User Permissions
```bash
# Add Docker official GPG key & repository
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Grant your user permission to run Docker without sudo
sudo usermod -aG docker $USER
newgrp docker
```

### 1.3 Install `kubectl` (Kubernetes CLI)
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### 1.4 Install `helm` (Package Manager for K8s)
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

### 1.5 Install `kind` (Kubernetes in Docker)
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```

### 1.6 Install `argocd` CLI
```bash
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

---

## 🧹 Step 2: Clean Up Previous Docker State (Optional)

```bash
cd /home/saurabh/Project/sk/sk-gitops-manifests
./scripts/cleanup-all.sh
```

---

## 🚀 Step 3: Automated 1-Command Kind Cluster Bootstrap

```bash
cd /home/saurabh/Project/sk/sk-gitops-manifests
./scripts/setup-ubuntu-gitops.sh
```

This will automatically:
1. Start a **Kind cluster** (`skops`) with port mappings for HTTP (80) & HTTPS (443).
2. Install NGINX Ingress Controller for Kind.
3. Install ArgoCD using Server-Side Apply into `argocd` namespace.
4. Output your ArgoCD admin password.

---

## ☸️ Step 4: Deploying Full Stack (DB + Backend + Frontend) via Helm to Kind

```bash
cd /home/saurabh/Project/sk/sk-gitops-manifests
./scripts/sync-local.sh
```

---

## 🐙 Step 5: Connecting ArgoCD GitOps Controller

### 5.1 Access ArgoCD UI
In a separate terminal tab:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open browser: `https://localhost:8080` (Username: `admin`).

Retrieve admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### 5.2 Apply Declarative ArgoCD Applications
```bash
kubectl apply -f argocd/postgres-application.yaml
kubectl apply -f argocd/backend-application.yaml
kubectl apply -f argocd/frontend-application.yaml
```

---

## 🌐 Step 6: Local Ingress & Host Mapping Setup

With **Kind**, because port 80 is mapped directly to `127.0.0.1`, simply add this to `/etc/hosts`:

```bash
sudo nano /etc/hosts
```
Add line:
```text
127.0.0.1   skfabricator.local api.skfabricator.local
```

Now open directly:
- **Frontend App**: `http://skfabricator.local`
- **Backend API**: `http://api.skfabricator.local`
