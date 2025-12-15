# Task 005 — Install Local Observability Stack (Prometheus + Grafana)

## Intent

Bring up a **pinned, reproducible observability baseline** on the local `kind` cluster (`psk-local`) so we can:

- validate platform health quickly,
- have a known metrics surface before touching AWS,
- prepare for later GitOps ownership of platform services.

This is still **Phase 1 / local-only**. Imperative bootstrap is acceptable here.

## Changes

Create a dedicated local bootstrap area:

- `local/k8s/observability/install.yaml` (new)
  - Vendored Kubernetes manifests (no runtime downloads)
  - Pinned image versions
- `local/k8s/observability/observability.sh` (new)
  - `install` / `status` / `uninstall`
- `local/k8s/observability/README.md` (new)
  - operator workflow and access instructions

Update:

- `local/k8s/README.md` (updated)
  - add an Observability section and point to `local/k8s/observability/`

## Commands to Run

From repository root:

```bash
# Create local cluster
./local/k8s/kind.sh create

# (Recommended) Install ArgoCD first (keeps Phase 1 flow consistent)
./local/k8s/argocd/argocd.sh install

# Install observability stack
./local/k8s/observability/observability.sh install

# Verify
./local/k8s/observability/observability.sh status
kubectl -n monitoring get pods -o wide
```

Access UIs:

```bash
# Grafana
kubectl -n monitoring port-forward svc/grafana 3000:80

# Prometheus
kubectl -n monitoring port-forward svc/prometheus 9090:9090
```

Uninstall:

```bash
./local/k8s/observability/observability.sh uninstall
```

## Expected Output

- Namespace `monitoring` exists and is `Active`.
- `prometheus` pod is `Running` and `Ready`.
- `kube-state-metrics` pod is `Running` and `Ready`.
- `grafana` pod is `Running` and `Ready`.
- Grafana UI reachable at `http://localhost:3000` after port-forward.
- Prometheus UI reachable at `http://localhost:9090` after port-forward.
- `install` is idempotent.

## Notes

- Scope is intentionally minimal: Prometheus + Grafana + kube-state-metrics.
- No Alertmanager tuning, logs (Loki), or tracing in Phase 1.
- Storage is ephemeral (`emptyDir`) for local dev.
