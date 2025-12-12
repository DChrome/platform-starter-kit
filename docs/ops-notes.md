# Operations Notes — Platform Starter Kit

This document captures **operational decisions, conventions, and guardrails**
that are learned incrementally while building the platform.

It is intentionally minimal and evolves only when a decision has been
*exercised in practice*.

---

## Terraform Versioning & Dependency Policy

- Terraform CLI:
  - Project assumes Terraform **v1.14**
  - Major version upgrades are treated as explicit migration events

- Providers:
  - Providers are **pinned by major version** in each Terraform root
  - Patch and minor updates are allowed within the pinned major

- Lock files:
  - `.terraform.lock.hcl` is **committed** for every Terraform root
  - Provider upgrades are performed intentionally via:

    ```bash
    terraform init -upgrade
    ```

  - Lock file diffs are reviewed as part of the change

Rationale:

- Ensures deterministic behavior across machines and time
- Makes dependency changes explicit and reviewable
- Avoids silent drift caused by provider auto-upgrades

---

Last updated: *Phase 0*
