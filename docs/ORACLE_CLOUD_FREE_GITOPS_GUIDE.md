# Oracle Cloud Always Free (24GB RAM) + Cloudflare Zero-Trust Production Deployment Guide

This guide details how to host the **SK Fabricator & Erector** platform, PostgreSQL database, and ArgoCD GitOps engine on the internet for **$0/month forever** using Oracle Cloud Infrastructure (OCI) Always Free tier and Cloudflare Tunnels.

---

## 🏗️ Architecture Overview

```
                      Internet Users / Browsers
                                 │
                                 ▼
                     Cloudflare Edge Network (Global CDN & DDoS Protection)
                                 │
                   (Secure Cloudflare Tunnel / Outbound Only)
                                 │
┌────────────────────────────────┴─────────────────────────────────┐
│ Oracle Cloud Always Free VM (4 ARM vCPUs, 24 GB RAM, 200 GB Storage) │
│                                                                  │
│  Kubernetes Cluster (Kind / K3s)                                 │
│   ├── cloudflared Agent (Outbound Tunnel Service)                │
│   ├── Nginx Ingress Controller                                   │
│   ├── Argo CD GitOps Engine                                      │
│   ├── sk-fabricator-prod (Angular UI + .NET 10 API + PostgreSQL)│
│   └── Prometheus & Grafana Monitoring                            │
└──────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Provision Oracle Cloud Always Free VM ($0 Forever)

1. Sign up at [oracle.com/cloud/free](https://www.oracle.com/cloud/free/).
2. Navigate to **Compute** → **Instances** → **Create Instance**.
3. **Configuration Settings**:
   - **Name**: `sk-fabricator-gitops-node`
   - **Image**: `Ubuntu 22.04 LTS` (Minimal / Canonical)
   - **Shape**: Change Shape → Ampere (ARM) → `VM.Standard.A1.Flex`
   - **Resources**: Set to **4 OCPUs** and **24 GB RAM** (100% Free Forever limit).
   - **Networking**: Select Default Virtual Cloud Network (VCN).
   - **SSH Keys**: Upload your public SSH key (`cat ~/.ssh/id_rsa.pub`).
4. Click **Create** (Provisioning takes ~2 minutes).
5. Note the public IP address (e.g. `140.238.x.x`).

---

## Step 2: Prepare Oracle Cloud Server & Install Kubernetes

SSH into your new server:
```bash
ssh ubuntu@YOUR_ORACLE_PUBLIC_IP
```

Install Docker & Kind / K3s:
```bash
# Update OS packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git ufw

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu

# Install Kind & kubectl
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-arm64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
```

---

## Step 3: Clone GitOps Repo & Bootstrap Cluster

```bash
git clone https://github.com/saurabhvirkar/sk-fabricator-gitops.git
cd sk-fabricator-gitops

# Run automated cluster bootstrapper
./scripts/bootstrap-cluster.sh
```

---

## Step 4: Setup Cloudflare Zero-Trust Tunnel (Free Domain + SSL)

1. Log into [Cloudflare Zero Trust Console](https://one.dash.cloudflare.com/).
2. Go to **Networks** → **Tunnels** → **Create a Tunnel**.
3. **Tunnel Name**: `skfabricator-prod-tunnel` → Click Save.
4. Select **Docker** or **Connector** and copy the **`TUNNEL_TOKEN`** (the long base64 string).
5. On your Oracle Cloud VM, create the production tunnel secret:
   ```bash
   kubectl create secret generic cloudflare-tunnel-secret \
     --namespace=sk-fabricator-prod \
     --from-literal=TUNNEL_TOKEN="YOUR_COPIED_TOKEN_HERE"
   ```
6. Deploy the `cloudflared` agent daemon:
   ```bash
   kubectl apply -f platform/ingress/cloudflare-tunnel-prod.yaml
   ```

---

## Step 5: Route Public Hostnames in Cloudflare

In the Cloudflare Zero Trust Console under your tunnel settings, add **Public Hostnames**:

| Public Hostname | Service Type | Internal Cluster URL |
| :--- | :--- | :--- |
| `skfabricator.com` (or `yourdomain.com`) | HTTP | `frontend-ui.sk-fabricator-prod.svc.cluster.local:80` |
| `api.skfabricator.com` | HTTP | `backend-api.sk-fabricator-prod.svc.cluster.local:8080` |
| `argocd.skfabricator.com` | HTTP | `argocd-server.argocd.svc.cluster.local:80` |

---

## 🎯 Verification & Launch

1. Visit `https://skfabricator.com` in your browser.
2. Cloudflare will automatically handle free SSL certificates, global edge caching, and routing.
3. Access ArgoCD at `https://argocd.skfabricator.com` to monitor production GitOps deployments live!
