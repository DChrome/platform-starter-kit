# Task 003 — Create a Reproducible Local kind Cluster

## Intent

Establish the Phase 1 local Kubernetes baseline by adding a **reproducible kind cluster config**
and a minimal lifecycle script so any engineer can create/destroy the cluster the same way.

## Changes

- `local/k8s/kind-config.yaml` (new) — canonical kind cluster configuration
- `local/k8s/kind.sh` (new) — create / delete / status helpers (thin wrapper)
- `local/k8s/README.md` (new) — how to run it, expected outputs, troubleshooting notes

## Commands to Run

From repository root:

```bash
# Create cluster
./local/k8s/kind.sh create

# Verify access
kubectl cluster-info
kubectl get nodes -o wide
kubectl get ns

# Optional: check storage class exists (varies by kind version, but often present)
kubectl get storageclass

# Tear down
./local/k8s/kind.sh delete
````

## Expected Output

After `create`:

- `kind get clusters` shows `psk-local`.
- `kubectl get nodes` returns >= 1 node in `Ready` state.
- `kubectl get ns` shows standard namespaces (default/kube-system/etc.).

After `delete`:

- `kind get clusters` no longer lists the cluster.

## Notes

Design constraints for this task:

- No Helm installs yet. No ArgoCD yet. No ingress yet.
- Keep the config explicit and minimal:
