# GitHub Branch Protection Strategy & Requirements

To enforce a production-grade GitOps workflow across **`SkFabricatorAndErector-Backend`**, **`SkFabricatorAndErector-Frontend`**, and **`sk-fabricator-gitops`**, configure the following rules in GitHub Repository Settings (`Settings > Branches > Add branch ruleset / protection rule`).

---

## 1. Ruleset for `main` (Production Release Branch)

| Setting | Configuration | Rationale |
| :--- | :--- | :--- |
| **Branch Pattern** | `main` | Protects the production release baseline. |
| **Require a pull request before merging** | **Enabled** (Min 1 approval) | Prevents direct pushes to production. |
| **Dismiss stale pull request approvals** | **Enabled** | Ensures new commits trigger re-reviews. |
| **Require status checks to pass before merging** | **Enabled** | CI build, unit tests, & security scans must pass. |
| **Require branches to be up to date before merging** | **Enabled** | Eliminates integration drift. |
| **Require conversation resolution before merging** | **Enabled** | Ensures all review comments are resolved. |
| **Do not allow bypassing the above settings** | **Enabled** | Applies rules strictly to repository admins. |
| **Restrict force pushes** | **Blocked** | Prevents history rewrites on production. |
| **Restrict deletions** | **Blocked** | Prevents accidental branch deletion. |

---

## 2. Ruleset for `develop` (Integration Branch)

| Setting | Configuration | Rationale |
| :--- | :--- | :--- |
| **Branch Pattern** | `develop` | Protects the primary development integration branch. |
| **Require a pull request before merging** | **Enabled** (Min 1 approval) | Ensures peer code review for features. |
| **Require status checks to pass before merging** | **Enabled** | CI unit tests & Docker linting must pass. |
| **Restrict force pushes** | **Blocked** | Prevents rewriting shared integration history. |
| **Restrict deletions** | **Blocked** | Prevents deletion of active integration branch. |

---

## 3. Workflow Progression Matrix

```
  feature/* ──(PR)──> develop ──(PR)──> release/x.y.z ──(PR)──> main ──(Tag)──> vX.Y.Z
                         │                                         │
                         └──────────────(Merge back)───────────────┘
```
