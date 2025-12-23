# Local Kubernetes (kind)

> ⚠️ **Warning: Currently, only macOS is supported.**

This directory defines the **canonical local Kubernetes cluster** for the Platform Starter Kit.

> 💡 The commands listed below should be run from the repository root.

## Prerequisites

Install tooling (macOS):

```bash
./local/bootstrap/bootstrap-macos.sh
```

You need:

- Docker Desktop (running)
- `kind`
- `kubectl` (should be installed with Docker Desktop)

## Create the cluster

```bash
./local/k8s/kind.sh create
```

Verify:

```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl get ns
```

## Status

```bash
./local/k8s/kind.sh status
```

## Delete

```bash
./local/k8s/kind.sh delete
```

## Notes

- Cluster name is hard-coded to `psk-local` in `kind.sh` for reproducibility.
- The cluster is intentionally minimal (1 control-plane + 1 worker). We can scale later if/when needed.

## Install Argo CD

Argo CD is installed as a **local bootstrap** step (day-0 dependency) using a vendored, pinned manifest:

```bash
./local/k8s/argocd/argocd.sh install
./local/k8s/argocd/argocd.sh status
```

See: `local/k8s/argocd/README.md`

## GitOps ownership (ArgoCD)

After ArgoCD is installed, register the local GitOps entrypoint:

```bash
kubectl apply -n argocd -f gitops/envs/local/argocd/root.yaml
```

## Observability (Prometheus + Grafana)

Bring up a minimal local metrics + dashboards baseline (Prometheus, kube-state-metrics, Grafana).

```bash
./local/k8s/observability/observability.sh install
```

See: `local/k8s/observability/README.md`

## Local GitOps (Operator Loop)

### Inspect state

```bash
./local/k8s/gitops/status.sh
```

### Access UIs

```bash
./local/k8s/observability/port-forward.sh
```

### Force ArgoCD to re-read Git (use after manifest / branch changes)

ArgoCD has **two distinct mechanisms**:

- **Sync**
  Applies desired state *already rendered* by ArgoCD.

- **Refresh**
  Forces ArgoCD to:

  - re-fetch Git
  - re-render manifests
  - re-evaluate Application definitions

Force a hard refresh with:

```bash
./local/k8s/gitops/refresh.sh
```

### Test a branch locally

```bash
./local/k8s/gitops/use-branch.sh            # current branch
./local/k8s/gitops/use-branch.sh <branch>
```

### Reset to default branch tracking

```bash
./local/k8s/gitops/use-branch.sh HEAD
```
