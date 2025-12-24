# Terraform

This directory contains all Terraform-related code for the Platform Starter Kit.

It defines **how Terraform is structured, executed, and validated** in this repository.
Specific infrastructure, environments, and providers are introduced incrementally over time.

---

## Contract

The following rules apply to all Terraform code in this repository unless explicitly revised.

### Root modules

- Root modules are **self-contained deployment entrypoints** under `accounts/<env>/`.
- Each root represents an independent state boundary.
- Roots must not rely on shared `.tf` files, symlinks, or implicit includes.

### Execution safety

- Root modules must support:
  - `terraform init -backend=false`
  - `terraform validate`
- These commands must run **without cloud credentials** and **without triggering provider API calls**.

### Reuse and abstraction

- Reusable logic lives in `modules/`.
- Root modules are not treated as libraries.
- Duplication at the root level is acceptable when it improves clarity and operability.

### Testing

- Terraform code may include automated tests.
- Tests are expected to validate **contracts and invariants** (structure, inputs, outputs, conventions).
- Provider behavior and real infrastructure integration are validated separately.

---

## Local validation

A local validation entrypoint exists to run the supported Terraform checks consistently.

From the repository root:

```bash
./infra/terraform/bin/check.sh
```

This command is intended to be safe to run locally and suitable for automation.
