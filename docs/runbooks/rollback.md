# Runbook: Rollback Strategy

## Instant Rollback via GitOps

Because all environment configurations reference immutable image tags, rolling back is entirely deterministic:

### 1. Revert Git Commit
```bash
git revert HEAD
git push origin main
```

### 2. Force Sync via Argo CD
```bash
argocd app sync skfabricator-backend-prod --force
argocd app sync skfabricator-frontend-prod --force
```

No manual `kubectl set image` or direct cluster interventions are permitted.
