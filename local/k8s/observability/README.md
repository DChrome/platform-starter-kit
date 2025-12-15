# Local Observability (Prometheus + Grafana)

This directory bootstraps a minimal observability stack into the **local kind cluster** (`psk-local`).

This is a **Phase 1** bootstrap step. The install is imperative and uses vendored manifests.

## Versions (Pinned)

Pinned in `observability.sh`:

- Prometheus: `prom/prometheus:v3.8.0`
- Grafana: `grafana/grafana:12.3.0`
- kube-state-metrics: `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0`

> Note: tags are pinned for reproducibility. Bumps should be explicit PRs.

## Prerequisites

- `kubectl`
- local cluster exists: `./local/k8s/kind.sh create`

(Recommended) Install ArgoCD first to keep the Phase 1 flow consistent:

```bash
./local/k8s/argocd/argocd.sh install
```

## Install

```bash
./local/k8s/observability/observability.sh install
```

## Status

```bash
./local/k8s/observability/observability.sh status
kubectl -n monitoring get pods -o wide
```

## Access

Grafana:

```bash
kubectl -n monitoring port-forward svc/grafana 3000:80
```

- UI: `http://localhost:3000`
- Credentials (local/dev only): `admin` / `admin`
- Prometheus datasource is provisioned automatically.

Prometheus:

```bash
kubectl -n monitoring port-forward svc/prometheus 9090:9090
```

- UI: `http://localhost:9090`

## Uninstall

```bash
./local/k8s/observability/observability.sh uninstall
```

## Notes / Design Constraints

- Storage is ephemeral (`emptyDir`).
- Scope is intentionally minimal (no Loki, no tracing, no alerting tuning).
- Prometheus scrapes:
  - itself
  - kube-state-metrics
  - kubelet `/metrics` and `/metrics/cadvisor` via the API server proxy
