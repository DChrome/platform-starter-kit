# Task 008 — Terraform Contract & Local Test Harness

## Goal

Establish a **fully local, zero-cost validation and testing harness** that all future Terraform work must pass.

This task ensures Terraform code is **reviewable, executable, and testable without cloud access**, in line with Infrastructure as Code principles.

## Scope

This task includes:

* Introducing a **canonical local workflow** for Terraform checks
* Adding Terraform-native contract tests using `terraform test`, focused on validating inputs, outputs, locals, and structural invariants (not provider behavior)
* Ensuring all checks can be executed via a single local command (CI-ready but not integrated into any CI system in this phase)

This task does **not** introduce any real infrastructure.

## Non-Goals

* No AWS accounts or credentials
* No remote state backends
* No cloud provider integration
* No CI system setup or pull-request enforcement

## Deliverables

* At least one minimal Terraform module with:

  * explicit inputs and outputs
  * no provider-side effects
  * passing `terraform test` coverage using mocks

* A single local entrypoint (script) that runs:

  * `terraform fmt -check`
  * `terraform validate`
  * `terraform test`

* Documentation describing the enforced Terraform contracts and local workflow

## Changes

* `infra/terraform/bin/check.sh` (new)
* `infra/terraform/modules/foundation_contracts/` (new)

  * `main.tf`
  * `variables.tf`
  * `outputs.tf`
  * `versions.tf`

* `infra/terraform/modules/foundation_contracts/tests/basic.tftest.hcl` (new)
* `infra/terraform/README.md` (new, short)

  * what the contract is
  * how to run `bin/check.sh`

## Acceptance Criteria

* All Terraform checks and tests run successfully:

  * on a clean local machine
  * no cloud credentials, no provider API calls, and no side effects
