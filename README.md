# SK Fabricator & Erector — GitOps Infrastructure Repository (`sk-fabricator-gitops`)

This repository serves as the **Single Source of Truth** for deploying and managing the **SK Fabricator & Erector Platform** using **GitOps, Helm 3, Kubernetes (K3s/Kind), and Argo CD**.

---

## 🏗 Stack Overview

- **Frontend**: Angular 21.2.x + Nginx (Multi-Stage Docker, Hardened Non-Root Container)
- **Backend**: ASP.NET Core 10 Web API (Clean Architecture, Non-Root Container, EF Core, JWT Auth)
- **Database**: PostgreSQL 16 (StatefulSet, Volume Claims, Secret Credentials)
- **GitOps Controller**: Argo CD (App-of-Apps, Environment AppProjects)
- **Security**: Kubernetes Restricted Pod Security Standards, Zero-Trust NetworkPolicies, No Plaintext Secrets in Git

---

## 📁 Repository Structure

```
sk-fabricator-gitops/
├── bootstrap/                         # Infrastructure Bootstrap Manifests
│   ├── namespaces/                    # Environment Namespaces (dev, staging, prod)
│   └── argocd-projects/               # Argo CD AppProject Definitions
│
├── argocd/                            # Argo CD Application Manifests
│   ├── dev/                           # Dev Environment Applications
│   ├── staging/                       # Staging Environment Applications
│   ├── prod/                          # Production Environment Applications
│   └── root-application.yaml          # Root App-of-Apps Generator
│
├── charts/                            # Hardened Microservice Helm Charts
│   ├── backend/                       # ASP.NET Core 10 API Helm Chart
│   ├── frontend/                      # Angular 21 UI Helm Chart
│   └── postgres/                      # PostgreSQL StatefulSet Helm Chart
│
├── environments/                      # Environment Value Overrides
│   ├── dev/                           # Local Development Overrides
│   ├── staging/                       # Staging Environment Overrides
│   └── prod/                          # Production Environment Overrides
│
├── platform/                          # Cluster Security & Governance
│   ├── network-policies/              # Zero-Trust Pod Isolation Policies
│   ├── pod-security/                  # Pod Security Standards & Policies
│   ├── resource-quotas/               # ResourceQuota & LimitRange Manifests
│   ├── ingress/                       # Cloudflare & Nginx Routing
│   └── backup/                        # PostgreSQL Backup CronJobs
│
├── scripts/                           # Local & Cloud Deployment Automation
└── docs/                              # Architecture, Security, & Operational Runbooks
    ├── architecture/                  # Architectural Overview & Topology
    ├── security/                      # Security Architecture & Controls
    └── runbooks/                      # Ops Runbooks (Deploy, Rollback, DB Backup/Restore)
```

---

## 🔒 Security Architecture Highlights

1. **No Plaintext Passwords**: Database passwords and API keys are injected exclusively via Kubernetes `Secret` objects.
2. **Immutable Artifact Promotion**: Deployments reference explicit container image tags (`1.0.0`) and SHA256 digests rather than mutable `latest` tags.
3. **Zero-Trust NetworkPolicies**: Default-deny all traffic except explicit flow: `Ingress -> Frontend -> Backend -> PostgreSQL`.
4. **Restricted Pod Security**: All containers run with `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, and `capabilities.drop: ["ALL"]`.

---

## 🚀 Quick Start (Development Bootstrap)

### 1. Apply Infrastructure Namespaces & AppProjects
```bash
kubectl apply -f bootstrap/namespaces/namespaces.yaml
kubectl apply -f bootstrap/argocd-projects/
```

### 2. Register Root Argo CD Application
```bash
kubectl apply -f argocd/root-application.yaml
```

---

## 📚 Operational Runbooks

Refer to [docs/runbooks/](docs/runbooks/) for step-by-step guidance on:
- [Deployment & Environment Promotion](docs/runbooks/deploy.md)
- [Rollback Strategy](docs/runbooks/rollback.md)
- [Database Backup & Disaster Recovery](docs/runbooks/database-backup-restore.md)
