# Task `<ID> — <Short Title>`

## Intent

A short explanation of what this task achieves and why it exists.

## Changes

List each file touched or created.

Example:

- `local/k8s/kind-cluster.yaml` (new)
- `local/k8s/README.md` (updated)

## Commands to Run

Exact shell commands required to complete the task.

Example:

```bash
kind create cluster --config local/k8s/kind-cluster.yaml
````

## Expected Output

Describe what the engineer should see if the task is completed correctly.

Example:

- `kubectl get nodes` returns 1 Ready node.
- ArgoCD UI is reachable via port-forward on `localhost:8080`.

## Notes

Optional clarifications, references, or future tasks that depend on this one.
