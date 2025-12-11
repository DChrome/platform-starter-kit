# Task 001 — Install Local Tooling

## Intent
Ensure the workstation has the core CLI tools required for local Kubernetes work
and for later Terraform + AWS tasks. This avoids debugging failures caused by missing tools.

## Changes
- Add a short “Local Tooling Requirements” section to `docs/ops-notes.md`.

## Commands
Verify each tool is installed and available:

```bash
docker version
kubectl version --client
kind version
helm version
terraform version
aws --version
```

## Expected Output

Each command prints a valid version.
No cluster created yet — success here simply means you have the prerequisites installed.
