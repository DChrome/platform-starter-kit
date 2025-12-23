# Task 007 — Establish a Local Platform Operator Loop (ArgoCD + Observability)

## Intent

Establish a **fast, predictable operator loop** for the local (`kind`) environment, focused on **observing, verifying, and troubleshooting platform services** managed via GitOps.

This task does **not** optimize application development (no workloads exist yet).
Instead, it ensures that operating the platform itself is **low-friction, explicit, and repeatable**, while preserving GitOps ownership.

After this task:

* Platform operators can quickly:

  * inspect ArgoCD state,
  * verify observability health,
  * access UIs,
  * switch branches for local testing.
* ArgoCD refresh vs sync behavior is explicit and documented.
* Local branch testing is supported.

---

## Changes

### Add — Local operator helper scripts

* `local/k8s/gitops/refresh.sh`
  Force ArgoCD to re-evaluate Git state for `root-local`.

* `local/k8s/gitops/status.sh`
  Quick snapshot of GitOps + observability health.

* `local/k8s/gitops/use-branch.sh`
  Patch ArgoCD Applications to track a specific Git branch for local testing.

* `local/k8s/observability/port-forward.sh`
  Single command to access Grafana and Prometheus locally.

### Modify — Documentation

* `local/k8s/README.md`
  Add a **“Local platform operator loop”** section describing:

  * supported workflows,
  * refresh vs sync semantics,
  * branch-based local testing.

---

## Default Git Tracking Model

All committed ArgoCD Application manifests must use:

```yaml
targetRevision: HEAD
```

This ensures:

* independence from `master` vs `main`,
* predictable behavior across environments,
* no branch-specific state stored in Git.

Branch selection for local testing is an **operator action**, not a declarative environment change.

---

## Supported Local Operator Loop

The following loop is **explicitly supported** for Phase-1:

1. Change GitOps config under:

   * `gitops/envs/local/`
   * `gitops/platform/`

2. Commit and push changes to any branch.
3. Switch local ArgoCD to that branch:

   ```bash
   ./local/k8s/gitops/use-branch.sh
   ```

4. Inspect platform state:

   ```bash
   ./local/k8s/gitops/status.sh
   ```

5. Access observability UIs:

   ```bash
   ./local/k8s/observability/port-forward.sh
   ```

### Reset to default tracking

Before merging to the default branch, reset ArgoCD to track `HEAD`:

```bash
./local/k8s/gitops/use-branch.sh HEAD
```

---

## Expected Output

This task is complete when:

* Platform state can be inspected without opening the ArgoCD UI.
* Grafana and Prometheus are reachable with a single command.
* Local branch testing works without modifying committed manifests.
* ArgoCD refresh behavior is explicit and predictable.
* No GitOps boundaries are weakened.

---

## Notes

### Why this task exists

Without this task:

* ArgoCD behavior appears inconsistent (sync vs refresh),
* local iteration feels slow,
* developers are tempted to encode branch logic in Git.

This task ensures the **correct GitOps path is also the fastest path**.
