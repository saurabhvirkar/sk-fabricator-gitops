# Security Architecture & Controls

## Security Principles

1. **Least Privilege & Zero-Trust**:
   - Pods only communicate over explicit allowed channels via NetworkPolicies.
   - Database is accessible ONLY from the backend API pods.
2. **Non-Root Execution**:
   - Backend runs as non-root user (UID 1000).
   - Frontend runs as unprivileged user (UID 101).
   - PostgreSQL runs as unprivileged user (UID 999).
3. **Immutability & Integrity**:
   - No `latest` image tags in staging or production.
   - Production releases use pinned semantic tags and SHA256 digests.
4. **Secrets Management**:
   - Plaintext credentials are strictly prohibited in Git.
   - Secrets are injected directly via Kubernetes `Secret` objects or External Secrets Operator.
