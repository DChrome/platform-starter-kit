# Argo CD (local bootstrap)

This directory bootstraps **Argo CD** into the local kind cluster.
We install it imperatively from a **vendored** manifest to avoid drift.

## Prerequisites

- Local cluster exists:

  ```bash
  ./local/k8s/kind.sh create
  ```

## Install

```bash
./local/k8s/argocd/argocd.sh install
```

## Access the UI

Port-forward the Argo CD API/UI:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Then open `https://localhost:8080` (you should expect a browser TLS warning).

### Initial admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

- Username: `admin`

## Status

```bash
./local/k8s/argocd/argocd.sh status
```

## Uninstall

```bash
./local/k8s/argocd/argocd.sh uninstall
```

## Notes

- The Argo CD installation manifest is committed as `install.yaml`.
- Upstream reference:
  - <https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml>
