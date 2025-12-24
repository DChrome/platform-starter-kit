terraform {
  # Keep this aligned with root modules. This module is pure (no providers/resources),
  # but we still pin Terraform to avoid subtle behavior drift.
  required_version = "~> 1.14.0"
}
