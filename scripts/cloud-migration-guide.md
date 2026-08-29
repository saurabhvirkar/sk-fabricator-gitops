# AWS & Azure Free Tier GitOps Migration Guide

This guide details how to deploy the exact same GitOps setup (Backend + Frontend + Helm + ArgoCD) to **AWS Free Tier** or **Azure Free Tier** with **Zero Code Changes**.

---

## 1. Cloud Architecture Overview

Because we built the application with **pure Helm Charts** and **Kubernetes primitives**, the application manifests are 100% cloud-agnostic.

```
+-----------------------------------------------------------------------+
|                       CLOUD INFRASTRUCTURE                            |
|                                                                       |
|  AWS (t2.micro / t3.micro Free Tier)  OR  Azure (B1s VM Free Tier)    |
|  +-----------------------------------------------------------------+  |
|  |                       K3s / MicroK8s Cluster                    |  |
|  |                                                                 |  |
|  |  +-------------------+   +-----------------------------------+  |  |
|  |  | ArgoCD Controller |   | NGINX Ingress Controller / Cert   |  |  |
|  |  +---------+---------+   +-----------------------------------+  |  |
|  |            |                                                    |  |
|  |            v (Pull from Git)                                    |  |
|  |  +------------------------+      +---------------------------+  |  |
|  |  | Backend (.NET API)     |      | Frontend (Angular/Nginx)  |  |  |
|  |  | Replicas: prod-values  |      | Replicas: prod-values     |  |  |
|  |  +------------------------+      +---------------------------+  |  |
|  +-----------------------------------------------------------------+  |
+-----------------------------------------------------------------------+
```

---

## 2. Option A: AWS Free Tier Deployment (EC2 + K3s / EKS)

### Step 1: Launch AWS Free Tier Instance
1. Log in to AWS Management Console and launch an **EC2 Instance** (`t2.micro` or `t3.micro` - 12 Months Free).
2. Choose **Ubuntu 24.04 LTS** as the OS.
3. Open Ingress Security Group Ports:
   - `22` (SSH)
   - `80` (HTTP)
   - `443` (HTTPS / ArgoCD)
   - `6443` (Kubernetes API - optional for remote kubectl)

### Step 2: Install Lightweight K3s & ArgoCD on EC2
Run on the EC2 SSH terminal:
```bash
# Install lightweight K3s (uses under 500MB RAM)
curl -sfL https://get.k3s.io | sh -

# Configure kubectl permission
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

# Install Helm 3
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Step 3: Connect ArgoCD to your GitOps Repository
```bash
kubectl apply -n argocd -f gitops/argocd/root-application.yaml
```

ArgoCD will automatically pull your Helm charts from Git, deploy the backend & frontend, and handle zero-downtime updates!

---

## 3. Option B: Azure Free Tier Deployment (Azure VM + K3s)

### Step 1: Launch Azure Free Tier VM
1. Go to Azure Portal -> Create Resource -> **Virtual Machine**.
2. Select **B1s (1 vCPU, 1 GiB RAM)** (Free for 12 months).
3. Select **Ubuntu Server 24.04 LTS**.
4. In Networking, allow HTTP (80), HTTPS (443), and SSH (22).

### Step 2: Install K3s & ArgoCD
Execute the exact same 3 steps as AWS above. Because K3s runs lightweight on Ubuntu, it operates smoothly within the free tier memory footprint.

---

## 4. Environment Override Selection in ArgoCD

To switch between environments in ArgoCD, simply change `valueFiles` in `gitops/argocd/backend-application.yaml` and `frontend-application.yaml`:

- **Development**: `../../environments/dev/backend-values.yaml`
- **Staging**: `../../environments/staging/backend-values.yaml`
- **Production**: `../../environments/prod/backend-values.yaml`

---

## 5. Summary Checklist

- [x] Zero application code changes needed when migrating.
- [x] Git commits trigger automated builds in GitHub Actions.
- [x] Docker images stored free on `ghcr.io`.
- [x] ArgoCD automatically syncs cloud cluster state with Git.
