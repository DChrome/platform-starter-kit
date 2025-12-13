# Task 004 — Install ArgoCD Locally

## Intent

Bring up a **pinned, reproducible ArgoCD installation** on the local `kind` cluster (`psk-local`) to establish the Phase 1 GitOps control plane. This is explicitly a **day-0 bootstrap** step (imperative is acceptable here); we are not introducing App-of-Apps or managing ArgoCD via itself yet.

Success means: ArgoCD is installed, healthy, and reachable locally in a predictable way.

## Changes

Create a dedicated ArgoCD bootstrap area under `local/k8s/argocd/`:

* `local/k8s/argocd/install.yaml` (new)
  Vendored ArgoCD "install" manifest, **pinned to a specific ArgoCD version** (do not `curl` at runtime).

* `local/k8s/argocd/argocd.sh` (new)
  Thin lifecycle wrapper:

  * `install` → creates namespace (if needed), applies `install.yaml`, waits for readiness
  * `status` → shows pods/deployments/svc and sync health signals
  * `uninstall` → removes ArgoCD resources (including namespace) safely/idempotently

* `local/k8s/argocd/README.md` (new)
  Minimal operator workflow:

  * prerequisites
  * install
  * port-forward
  * initial admin password retrieval
  * uninstall
  * common failure modes (e.g., Docker not running is handled by `kind.sh`)

* `local/k8s/README.md` (updated)
  Add a short "Next step: install ArgoCD" section and point to `local/k8s/argocd/`.

**Pinning requirement (non-negotiable for this task):**

* The pinned ArgoCD version must be recorded in one obvious place (either:

  * a comment header at the top of `install.yaml`, and/or
  * `ARGOCD_VERSION="vX.Y.Z"` in `argocd.sh` and referenced from README).

## Commands to Run

From repo root:

```bash
# 1) Create local cluster (includes Docker daemon sanity checks)
./local/k8s/kind.sh create

# 2) Install ArgoCD (vendored manifest, pinned)
./local/k8s/argocd/argocd.sh install

# 3) Verify status
./local/k8s/argocd/argocd.sh status
kubectl -n argocd get pods -o wide
```

Access the UI:

```bash
# Port-forward the ArgoCD API/UI
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Retrieve initial admin password (document this exact command in the README too):

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

Uninstall:

```bash
./local/k8s/argocd/argocd.sh uninstall
```

## Expected Output

* `./local/k8s/argocd/argocd.sh install` completes without error and is **idempotent** (re-running does not break the cluster).
* Namespace `argocd` exists:
  `kubectl get ns argocd` returns `Active`.
* ArgoCD core pods are `Running` and `Ready`:
  `kubectl -n argocd get pods` shows all expected components healthy (server, repo-server, application-controller, dex or equivalent depending on version).
* UI is reachable locally after port-forward:

  * `kubectl -n argocd port-forward svc/argocd-server 8080:443`
  * opening `https://localhost:8080` works (browser warning is expected due to self-signed TLS)
* You can log in as `admin` using the retrieved initial password.

## Notes

* Keep this task strictly to "ArgoCD exists and is reachable."
* Version pinning: pick a specific `vX.Y.Z` release and vendor the matching upstream `install.yaml`. If you later bump versions, do it as an explicit task/PR with a clear diff and rollout notes.
