# Task 006 — Establish GitOps Ownership for Local Platform Services

## Intent

Introduce **GitOps ownership** for Phase 1 platform services on the local `kind` cluster by making **ArgoCD** the reconciler for platform components.

After this task:

* **Environments are first-class deployment entrypoints** under `gitops/envs/<env>/`.
* **Platform services are reusable packages** under `gitops/platform/<service>/` (no environment logic, no ArgoCD Applications).
* **ArgoCD Applications are owned by environments**, not platform packages.
* Only `envs/local` is wired, but the structure extends cleanly to dev/prod later.

### Scope clarification

This task establishes GitOps ownership **inside a Kubernetes cluster only**. Cloud infrastructure (AWS accounts, VPCs, clusters, databases) is managed separately (Terraform) and is **out of scope**.

The GitOps `envs/<env>` hierarchy represents **Kubernetes deployment entrypoints**, not cloud infrastructure environments.

---

## Changes

### Add — Environment entrypoint (local)

**Environment index: includes all ArgoCD Application manifests for local.**

* `gitops/envs/local/kustomization.yaml` (new)

**Root ArgoCD Application (`root-local`) pointing at `gitops/envs/local`.**

* `gitops/envs/local/argocd/root.yaml` (new)

**Local environment ArgoCD Applications. Each deploys a platform service using Helm via ArgoCD.**

* `gitops/envs/local/argocd/apps/observability-prometheus.yaml` (new)
* `gitops/envs/local/argocd/apps/observability-grafana.yaml` (new)
* `gitops/envs/local/argocd/apps/observability-kube-state-metrics.yaml` (new)

**Local-only Helm overrides.**

* `gitops/envs/local/values/prometheus.yaml` (new)
* `gitops/envs/local/values/grafana.yaml` (new)
* `gitops/envs/local/values/kube-state-metrics.yaml` (new)

### Add — Platform packages (reusable, shared defaults for each component)

* `gitops/platform/observability/prometheus/values/common.yaml` (new)
* `gitops/platform/observability/grafana/values/common.yaml` (new)
* `gitops/platform/observability/kube-state-metrics/values/common.yaml` (new)

### Modify

* `local/k8s/README.md` (updated)
  Add a short “GitOps ownership (Task 006)” section with the exact command to apply `gitops/envs/local/argocd/root.yaml`.

---

## Commands to Run

From repository root:

```bash
# 1) Create local cluster (if not already)
./local/k8s/kind.sh create

# 2) Install ArgoCD (if not already)
./local/k8s/argocd/argocd.sh install
```

If observability was installed imperatively via Task 005 earlier, uninstall it first to avoid ownership conflicts:

```bash
./local/k8s/observability/observability.sh uninstall
```

Register the local environment root:

```bash
kubectl apply -n argocd -f gitops/envs/local/argocd/root.yaml
```

Verify reconciliation:

```bash
kubectl -n argocd get applications
kubectl -n monitoring get pods -o wide
```

Optional diagnostics:

```bash
kubectl -n argocd describe application root-local
kubectl -n argocd get events --sort-by=.lastTimestamp | tail -n 30
```

Access UIs (now GitOps-managed):

```bash
# Grafana
kubectl -n monitoring port-forward svc/grafana 3000:80

# Prometheus
kubectl -n monitoring port-forward svc/prometheus-server 9090:80
```

Ownership sanity check (reconciliation proof):

```bash
kubectl delete ns monitoring
# Wait and confirm ArgoCD recreates it
kubectl -n monitoring get pods -o wide
```

---

## Expected Output

This task is complete when all of the following are true:

* ArgoCD shows `root-local` as `Healthy` and `Synced`.
* ArgoCD shows three child Applications (names may vary, but three distinct apps exist):

  * Prometheus
  * Grafana
  * kube-state-metrics

* Namespace `monitoring` exists and all pods are `Running/Ready`.
* Deleting namespace `monitoring` results in ArgoCD recreating it and restoring workloads.

---

## Notes

### Boundary rules (non-negotiable)

* `gitops/envs/<env>/` owns **deployment entrypoints**:

  * ArgoCD Applications
  * environment-specific overrides
  * environment composition

* `gitops/platform/<service>/` owns **reusable packages**:

  * common values defaults
  * chart/source pinning info (via ArgoCD app manifests, not runtime scripts)
  * **must not** contain ArgoCD Applications or environment branching

* `local/` owns **bootstrap ergonomics only**:

  * scripts and docs to create cluster and install ArgoCD
  * must not become a dependency for `gitops/`

### Helm via ArgoCD (implementation constraint)

Each service Application must:

* pin chart source and chart version in ArgoCD (`repoURL`, `chart`, `targetRevision`)
* apply values in two layers:

  1. platform common defaults: `gitops/platform/.../values/common.yaml`
  2. env local overrides: `gitops/envs/local/values/<component>.yaml`

### Naming & multi-cluster sanity

This layout assumes the normal model: **one ArgoCD per cluster**. In that model, `root-local` and related Application names can remain stable across clusters.

If we later run a single ArgoCD instance managing multiple clusters, Application names must include a cluster identifier suffix to avoid collisions (e.g., `root-local-<cluster-id>`).

### Minimal labels (recommended)

Add lightweight labels to ArgoCD Application manifests to aid filtering and future automation:

* `psk.dev/env: local`
* `psk.dev/component: observability`
* `psk.dev/managed-by: argocd`
