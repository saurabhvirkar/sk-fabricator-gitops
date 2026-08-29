# SK Fabricator & Erector — GitOps Infrastructure Repository (`sk-gitops-manifests`)

This repository is the **Single Source of Truth** for deploying and managing the **SK Fabricator & Erector Microservices Architecture** via **GitOps, Helm 3, Kubernetes, and ArgoCD**.

---

## 📁 Repository Structure

```
sk-gitops-manifests/
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
│   ├── dev/                           # Local Ubuntu / Minikube Dev values
│   ├── staging/                       # Staging Environment values
│   └── prod/                          # Production AWS / Azure Free Tier values
│
├── workflows/                         # GitHub Action CI Templates
│   ├── backend-gitops-ci.yml          # Copy to Backend repo when ready
│   └── frontend-gitops-ci.yml         # Copy to Frontend repo when ready
│
└── scripts/                           # Local & Cloud Automation Scripts
    ├── setup-ubuntu-gitops.sh         # Bootstrap K8s, Helm & ArgoCD on Ubuntu
    ├── sync-local.sh                  # Local Helm rendering & cluster deployment test
    ├── LOCAL_UBUNTU_GITOPS_GUIDE.md   # Step-by-step local Ubuntu guide
    └── cloud-migration-guide.md       # AWS & Azure Free Tier deployment guide
```

---

## 🚀 Quick Start on Local Ubuntu Terminal

### 1. Bootstrap Local K8s & ArgoCD
```bash
./scripts/setup-ubuntu-gitops.sh
```

### 2. Test Local Deployment (No Remote Git Needed)
```bash
./scripts/sync-local.sh
```

---

## 🔗 How to Connect to GitHub Remote Repo

1. Create a new GitHub Repository named **`sk-gitops-manifests`**.
2. Run in this directory:
   ```bash
   git add .
   git commit -m "feat: initial commit for sk-gitops-manifests microservices repository"
   git branch -M main
   git remote add origin https://github.com/YOUR_GITHUB_USERNAME/sk-gitops-manifests.git
   git push -u origin main
   ```
3. Update `repoURL` in `argocd/*.yaml` to point to your GitHub URL.
