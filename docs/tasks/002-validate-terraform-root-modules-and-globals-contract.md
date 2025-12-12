# Task 002 — Validate Terraform Root Modules & Globals Contract

## Intent

Establish and validate the **Terraform root-module contract** for this project.

After this task, each environment root (dev/prod) must be:

- self-contained,
- runnable independently,
- consistent in provider and version constraints,
- safe to validate without touching AWS.

This task explicitly prioritizes **operability, reviewability, and workflow clarity** over aggressive DRY. Reuse will be introduced later via Terraform modules, not shared root boilerplate.

## Changes

Implement the following minimal, explicit structure.

### Root module contract (mandatory)

Each environment root **must** contain:

- `main.tf`
- `versions.tf`
- `providers.tf`

Roots must not rely on `.tf` files from sibling directories. No symlinks, no file-generation, no implicit includes.

`providers.tf` must be safe to load without credentials:

- no data sources
- no backend configuration
- no assumptions about a specific AWS profile being present

### Files to add or verify

- `infra/terraform/accounts/dev/main.tf`
- `infra/terraform/accounts/dev/versions.tf`
- `infra/terraform/accounts/dev/providers.tf`

- `infra/terraform/accounts/prod/main.tf`
- `infra/terraform/accounts/prod/versions.tf`
- `infra/terraform/accounts/prod/providers.tf`

`main.tf` must be a no-op stub (locals / outputs only).  
No resources, data sources, modules, or backend configuration yet.

### DRY policy (explicit)

- Duplication of small root-level boilerplate is **intentional**.
- Behavioral reuse will happen through `infra/terraform/modules/*`.
- Consistency across roots will be enforced later via CI checks (e.g., diff/checksum), not shared files.

## Commands to Run

From repository root:

```bash
# Dev root
terraform -chdir=infra/terraform/accounts/dev init -backend=false
terraform -chdir=infra/terraform/accounts/dev fmt -check
terraform -chdir=infra/terraform/accounts/dev validate
terraform -chdir=infra/terraform/accounts/dev plan -refresh=false

# Prod root
terraform -chdir=infra/terraform/accounts/prod init -backend=false
terraform -chdir=infra/terraform/accounts/prod fmt -check
terraform -chdir=infra/terraform/accounts/prod validate
terraform -chdir=infra/terraform/accounts/prod plan -refresh=false
```

(Optional sanity check)

```bash
terraform -chdir=infra/terraform/accounts/dev providers
terraform -chdir=infra/terraform/accounts/prod providers
```

## Expected Output

- `init` succeeds for both dev and prod with `-backend=false`
- `fmt -check` passes
- `validate` passes
- `plan -refresh=false` shows **0 to add, 0 to change, 0 to destroy**
- No infrastructure is created or modified

## Notes

- Terraform root modules are **deployment entrypoints**, not libraries.
- Making roots self-contained reduces hidden coupling and improves reviewability.
- Remote state, backends, and real providers will be introduced in Phase 2.
- If dev/prod diverge at this stage, it is a failure of this task.
- Relative local module sources are acceptable initially; we'll consider git-tagged module sources once CI exists.
- `accounts/` represents the primary Terraform state boundary (cloud account / project / subscription). The name reflects AWS-first implementation, not a permanent provider constraint.
