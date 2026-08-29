# Complete Step-by-Step Guide: Running GitOps Stack Locally on Ubuntu Terminal

This guide provides basic-to-advanced, copy-paste terminal instructions to install all prerequisites, set up the local Kubernetes cluster, connect **Frontend + Backend + PostgreSQL Database**, and manage the entire environment via **ArgoCD GitOps** on Ubuntu OS.

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

### 1.5 Install `minikube` (Local Kubernetes Cluster)
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

### 1.6 Install `argocd` CLI
```bash
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

---

## 🚀 Step 2: Automated 1-Command Local GitOps Bootstrap

Navigate to your workspace directory:
```bash
cd /home/saurabh/Project/sk
```

Run the automated setup script created for your workspace:
```bash
./gitops/scripts/setup-ubuntu-gitops.sh
```

This will automatically:
1. Start Minikube with Docker driver and NGINX Ingress controller enabled.
2. Install ArgoCD into the `argocd` namespace.
3. Print your ArgoCD local URL and admin password.

---

## 📦 Step 3: Fast Local Testing (Docker Compose Method)

Before Kubernetes, if you want to quickly test Frontend + Backend + Database locally in Docker:

```bash
cd /home/saurabh/Project/sk/SkFabricatorAndErector-Backend

# Start PostgreSQL Database and .NET Backend API
docker compose up -d --build

# Verify container health
docker compose ps
```

Access local endpoints:
- **Backend API**: `http://localhost:8080/swagger` or `http://localhost:8080/healthz`
- **PostgreSQL DB**: `localhost:5432` (User: `postgres`, Password: `postgrespassword`, DB: `skfabricatordb`)

---

## ☸️ Step 4: Deploying Full Stack (DB + Backend + Frontend) via Helm to K8s

To deploy all three tiers into Kubernetes using Helm:

```bash
cd /home/saurabh/Project/sk

# Run the full-stack local deployment script
./gitops/scripts/sync-local.sh
```

### Manual Helm Commands (Basic to Advanced):
```bash
# 1. Deploy Database
helm upgrade --install postgres-db gitops/helm/postgres

# 2. Deploy Backend API
helm upgrade --install backend-api gitops/helm/backend -f gitops/environments/dev/backend-values.yaml

# 3. Deploy Frontend UI
helm upgrade --install frontend-ui gitops/helm/frontend -f gitops/environments/dev/frontend-values.yaml

# 4. Check status of running pods and services
kubectl get pods -w
kubectl get svc
kubectl get ingress
```

---

## 🐙 Step 5: Connecting ArgoCD GitOps Controller (Git as Truth)

### 5.1 Access ArgoCD UI
In a separate terminal tab, start port-forwarding:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open browser: `https://localhost:8080` (Bypass HTTPS warning).
- **Username**: `admin`
- **Password**: Get password using:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```

### 5.2 Apply Declarative ArgoCD Applications
```bash
# Deploy all applications via App-of-Apps pattern
kubectl apply -f gitops/argocd/postgres-application.yaml
kubectl apply -f gitops/argocd/backend-application.yaml
kubectl apply -f gitops/argocd/frontend-application.yaml
```

ArgoCD will now continuously monitor your `gitops/` directory. Whenever you commit changes to Git, ArgoCD will automatically sync the cluster!

---

## 🌐 Step 6: Local Ingress & Host Mapping Setup

To access `http://skfabricator.local` and `http://api.skfabricator.local` directly in your browser:

### 6.1 Get Minikube IP
```bash
minikube ip
```
*(Example output: `192.168.49.2`)*

### 6.2 Add Host Mappings in `/etc/hosts`
```bash
sudo nano /etc/hosts
```
Add the following line (replace `<MINIKUBE_IP>` with your minikube IP):
```text
<MINIKUBE_IP>   skfabricator.local api.skfabricator.local
```

Now open:
- **Frontend App**: `http://skfabricator.local`
- **Backend API**: `http://api.skfabricator.local`

---

## 🔍 Step 7: Useful Verification & Troubleshooting Commands

```bash
# View live logs of Backend API
kubectl logs -l app.kubernetes.io/instance=backend-api -f

# View live logs of PostgreSQL Database
kubectl logs -l app=postgres-db -f

# View live logs of Frontend UI
kubectl logs -l app.kubernetes.io/instance=frontend-ui -f

# Test Database connection from inside Backend Pod
kubectl exec -it deployment/backend-api -- env | grep ConnectionStrings
```
