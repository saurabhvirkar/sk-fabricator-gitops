# Architecture Overview — SK Fabricator & Erector

## Topology

```
                        INTERNET
                           │
                           ▼
                 ┌──────────────────┐
                 │    Cloudflare    │
                 │ DNS / WAF / TLS  │
                 └────────┬─────────┘
                          │
                          │ HTTPS
                          ▼
             ┌───────────────────────────┐
             │       K3s Cluster         │
             │                           │
             │  ┌─────────────────────┐  │
             │  │  Ingress Controller │  │
             │  └──────────┬──────────┘  │
             │             │             │
             │      ┌──────┴──────┐      │
             │      ▼             ▼      │
             │   Frontend       Backend  │
             │  Angular 21     .NET 10   │
             │      │              │     │
             │      │ TCP 8080     ▼     │
             │      │         PostgreSQL │
             │      │          TCP 5432  │
             │      └──────────────┘     │
             │                           │
             │ NetworkPolicies            │
             │ Pod Security (Restricted) │
             └────────────┬──────────────┘
                          │
                          │ GitOps Sync
                          ▼
                  ┌──────────────────┐
                  │     Argo CD      │
                  └────────┬─────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │ sk-fabricator-     │
                 │ gitops             │
                 └────────────────────┘
```

## Workload Boundaries

| Environment | Namespace | Argo CD Project | Promotion Trigger |
| :--- | :--- | :--- | :--- |
| **Dev** | `sk-fabricator-dev` | `skfabricator-dev` | Automatic on Git Push |
| **Staging** | `sk-fabricator-staging` | `skfabricator-staging` | Automatic PR Merge |
| **Prod** | `sk-fabricator-prod` | `skfabricator-prod` | Manual Approval PR |
