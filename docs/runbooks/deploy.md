# Runbook: Deployment & Environment Promotion

## Release Flow

```
Developer Push -> CI Pipeline (Test, SAST, Docker Build) -> Push GHCR Image (Tag: 1.x.x) -> GitOps PR -> Argo CD Sync
```

## Step-by-Step Production Promotion

1. Verify CI has built and published image to `ghcr.io/saurabhvirkar/skfabricator-backend:1.x.x` and `ghcr.io/saurabhvirkar/skfabricator-frontend:1.x.x`.
2. Create a Pull Request in `sk-fabricator-gitops` modifying:
   - `environments/prod/backend-values.yaml` -> `image.tag`
   - `environments/prod/frontend-values.yaml` -> `image.tag`
3. After review and merge into `main`, sync via Argo CD:
   ```bash
   argocd app sync skfabricator-backend-prod
   argocd app sync skfabricator-frontend-prod
   ```
