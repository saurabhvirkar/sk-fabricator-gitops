# SK Fabricator & Erector — GitOps Infrastructure Repository (`sk-fabricator-gitops`)

This repository is the **Single Source of Truth** for deploying and managing the **SK Fabricator & Erector Microservices Architecture** via **GitOps, Helm 3, Kubernetes (Kind), and ArgoCD**.

---

## 📁 Repository Structure

```
sk-fabricator-gitops/
├── argocd/                            # ArgoCD Application Manifests (App-of-Apps Pattern)
│   ├── root-application.yaml          # Root controller application
│   ├── backend-application.yaml       # Backend API ArgoCD application
│   ├── frontend-application.yaml      # Frontend UI ArgoCD application
│   └── postgres-application.yaml      # PostgreSQL DB ArgoCD application
│
├── helm/                              # Microservices Production Helm 3 Charts
│   ├── backend/                       # .NET 10 API Helm Chart
│   ├── frontend/                      # Angular 19 + Nginx UI Helm Chart
│   └── postgres/                      # PostgreSQL Database Helm Chart
│
├── environments/                      # Environment Configuration Overrides
│   ├── dev/                           # Local Ubuntu Kind Dev values
│   ├── staging/                       # Staging Environment values
│   └── prod/                          # Production AWS / Azure Free Tier values
│
├── workflows/                         # GitHub Action CI Templates
│   ├── backend-gitops-ci.yml          # Copy to Backend repo when ready
│   └── frontend-gitops-ci.yml         # Copy to Frontend repo when ready
│
└── scripts/                           # Local & Cloud Automation Scripts
    ├── setup-ubuntu-gitops.sh         # Bootstrap Kind, Helm & ArgoCD on Ubuntu
    ├── sync-local.sh                  # Build local images & deploy Helm stack
    ├── cleanup-all.sh                 # Clean up Docker containers & Kind cluster
    ├── LOCAL_UBUNTU_GITOPS_GUIDE.md   # Step-by-step local Ubuntu guide
    └── cloud-migration-guide.md       # AWS & Azure Free Tier deployment guide
```

---

## 🚀 Quick Start on Local Ubuntu Terminal

### 1. Bootstrap Local K8s & ArgoCD
```bash
./scripts/setup-ubuntu-gitops.sh
```

### 2. Test Local Deployment (Auto-Build & Deploy)
```bash
./scripts/sync-local.sh
```

---

## 🔗 How to Connect to GitHub Remote Repo

1. Create a new GitHub Repository named **`sk-fabricator-gitops`**.
2. Run in this directory:
   ```bash
   git add .
   git commit -m "feat: initial commit for sk-fabricator-gitops repository"
   git branch -M main
   git remote add origin https://github.com/saurabhvirkar/sk-fabricator-gitops.git
   git push -u origin main
   ```
