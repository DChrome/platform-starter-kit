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
