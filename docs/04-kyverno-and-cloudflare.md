# Kyverno Security Governance & Cloudflare Tunnel Integration

This guide details the security policy engine (Kyverno) and Zero-Trust Cloudflare Tunnel setup for the **SK Fabricator & Erector** platform.

---

## 1. Kyverno Policy Governance

Kyverno runs natively in Kubernetes to enforce declarative policies on workloads across `sk-fabricator-stage` and `sk-fabricator-prod`.

### Applied Cluster Policies (`platform/kyverno/`)
1. **`disallow-latest-tag.yaml`** (Severity: High):
   - Rejects Pods that use mutable tags `:latest` or `dev-latest` in staging and production.
   - Requires explicit semantic versioning tags (e.g. `1.0.0`) or git commit SHAs.

2. **`require-non-root.yaml`** (Severity: High):
   - Enforces `securityContext.runAsNonRoot: true` across all pods in non-dev namespaces.
   - Prevents root privilege escalation.

3. **`require-resource-limits.yaml`** (Severity: Medium):
   - Audits and ensures containers define explicit CPU and Memory requests and limits.

### Installation & Enforcement
To install Kyverno in the cluster via Helm:
```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```
Apply policies:
```bash
kubectl apply -f platform/kyverno/
```

---

## 2. Cloudflare Tunnel Zero-Trust Setup (`platform/ingress/cloudflare-tunnel-prod.yaml`)

Cloudflare Tunnel (`cloudflared`) connects production ingress services directly to Cloudflare's Edge Network without exposing any inbound public IP ports on your Kubernetes cluster node.

### Steps to Provision Cloudflare Tunnel for Production

1. **Create Cloudflare Tunnel**:
   Log into Cloudflare Zero Trust Console -> Access -> Tunnels -> Create Tunnel -> Name: `skfabricator-prod-tunnel`.
2. **Retrieve Tunnel Token**:
   Copy the `TUNNEL_TOKEN` from the Cloudflare console.
3. **Provision Kubernetes Secret**:
   ```bash
   kubectl create secret generic cloudflare-tunnel-secret \
     --namespace=sk-fabricator-prod \
     --from-literal=TUNNEL_TOKEN="YOUR_CLOUDFLARE_TUNNEL_TOKEN"
   ```
4. **Deploy Tunnel Agent**:
   ```bash
   kubectl apply -f platform/ingress/cloudflare-tunnel-prod.yaml
   ```
5. **Configure Ingress Routing in Cloudflare**:
   In Cloudflare Zero Trust Console, add Public Hostnames:
   - `skfabricator.com` -> `http://frontend-ui.sk-fabricator-prod.svc.cluster.local:80`
   - `api.skfabricator.com` -> `http://backend-api.sk-fabricator-prod.svc.cluster.local:8080`

### Security Benefits
- **Zero Inbound Ports**: Cluster firewalls block all incoming TCP ports.
- **DDoS Mitigation**: Automated L3/L4/L7 DDoS protection by Cloudflare Edge.
- **WAF Rules**: Web Application Firewall rules protect ASP.NET Core API from SQLi, XSS, and bot attacks.
