# Phase 0 Audit Report: SK Fabricator & Erector GitOps Architecture

**Date**: 2026-08-30  
**Status**: Completed  

---

## 1. Audit Summary

This audit verifies the exact status of the three repositories in the **SK Fabricator & Erector** project prior to proceeding with the parallel GitOps rollout.

### Ground Rules Compliance
- **Render Production Untouched**: `render.yaml`, `cd.yml`, `deploy-production.yml`, and live deployment hooks in `SkFabricatorAndErector-Backend` and `SkFabricatorAndErector-Frontend` are preserved without modification.
- **GitOps Isolation**: `sk-fabricator-gitops` operates independently from Render.
- **Same-Origin Routing**: Angular frontend uses `/api` relative URL mapped via Nginx reverse proxy to prevent CORS issues on Kubernetes.

---

## 2. Repo-by-Repo Status Table

| File / Folder Path | Repository | Status | Notes |
| :--- | :--- | :--- | :--- |
| `render.yaml` | Backend | Real (Frozen) | Defines Render deployment configuration. Kept untouched. |
| `.github/workflows/cd.yml` | Backend | Real (Frozen) | Triggers live Render deployments on `main` push. Untouched. |
| `.github/workflows/gitops-ci.yml` | Backend | Real | Dual registry CI workflow for GHCR and Docker Hub (`saurabhvirkar/skfabricator-backend`). |
| `src/SkFabricatorAndErector.Infrastructure/Persistence/DatabaseExtensions.cs` | Backend | Real (Fixed) | Enhanced PostgreSQL connection string parsing to handle `Host=` and `Server=` keywords gracefully. |
| `src/SkFabricatorAndErector.Infrastructure/Persistence/SeedData.cs` | Backend | Real (Fixed) | Ensured `admin@skfabricator.com` seeds with default password `Admin@123`. |
| `src/environments/environment.prod.ts` | Frontend | Real (Fixed) | Updated `apiUrl` from hardcoded Render URL to relative `/api`. |
| `nginx.conf` | Frontend | Real (Fixed) | Added reverse proxy location block `/api/` routing to `http://backend-api:8080/api/`. |
| `.github/workflows/gitops-ci.yml` | Frontend | Real | Dual registry CI workflow for GHCR and Docker Hub (`saurabhvirkar/skfabricator-frontend`). |
| `bootstrap/namespaces/namespaces.yaml` | GitOps | Real | Provisions `sk-fabricator-dev`, `sk-fabricator-stage`, and `sk-fabricator-prod` namespaces. |
| `bootstrap/argocd-projects/` | GitOps | Real | AppProjects for `dev`, `stage`, and `prod` with namespace restrictions. |
| `argocd/root-application.yaml` | GitOps | Real | App-of-apps entrypoint watching `sk-fabricator-gitops`. |
| `argocd/{dev,stage,prod}/` | GitOps | Real | Individual application manifests for Backend, Frontend, and PostgreSQL. |
| `charts/backend/` | GitOps | Real | Helm chart with Deployment, Service, Ingress, HPA, ServiceAccount, ConfigMap. |
| `charts/frontend/` | GitOps | Real | Helm chart with Deployment, Service, Ingress, ServiceAccount, ConfigMap. |
| `charts/postgres/` | GitOps | Real | StatefulSet with PVC, headless service, and initialization scripts. |
| `environments/{dev,stage,prod}/` | GitOps | Real | Environment-specific `values.yaml` files. Updated to Docker Hub namespace. |
| `platform/network-policies/` | GitOps | Real | Zero-trust default-deny policy with explicit ingress/egress rules. |
| `platform/backup/postgres-backup-cronjob.yaml` | GitOps | Real | Automated daily PostgreSQL backup CronJob with `pg_dump`. |
| `scripts/sync-local.sh` | GitOps | Real | Automated image build and Kind cluster sync script. |
| `scripts/verify-cluster.sh` | GitOps | Real | Automated verification script checking pods, services, and health probes. |
| `docs/runbooks/` | GitOps | Real | Deploy, rollback, and database backup/restore runbooks. |

---

## 3. Findings & Key Decisions

1. **Database Provider Fallback Resolved**:
   - Fixed `DatabaseExtensions.cs` so EF Core correctly recognizes PostgreSQL connection strings containing `Host=` and `Database=` keywords, preventing accidental fallback to SQLite.
2. **Seed Admin Access Confirmed**:
   - Seed user `admin@skfabricator.com` with password `Admin@123` is enabled in `SeedData.cs`.
3. **CORS & Routing Solution Verified**:
   - Nginx inside `skfabricator-frontend` now proxies `/api/` requests directly to `http://backend-api:8080/api/` inside Kubernetes. `environment.prod.ts` uses relative `/api` path.
4. **Multi-Registry CI Configured**:
   - Both Frontend and Backend workflows push tags (`dev-latest`, `stage-latest`, `latest`, `1.0.0`) to Docker Hub (`saurabhvirkar/`) and GHCR seamlessly.

---

## 4. Phase 0 Audit Approval
- **Status**: Audit completed and verified.
- **Next Phase**: Proceeding with Phase 1 & Phase 2 verification and local cluster sync.
