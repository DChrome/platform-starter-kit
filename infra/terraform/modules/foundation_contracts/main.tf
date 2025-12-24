locals {
  project   = trimspace(lower(var.project))
  env       = trimspace(lower(var.env))
  component = var.component == null ? null : trimspace(lower(var.component))
  ns        = trimspace(lower(var.namespace))

  id = {
    project   = local.project
    env       = local.env
    component = local.component
  }

  name_prefix = local.component == null ? "${local.project}-${local.env}" : "${local.project}-${local.env}-${local.component}"

  # Provider-agnostic labels (useful to mirror K8s labeling conventions later).
  labels_base = {
    "${local.ns}/project"    = local.project
    "${local.ns}/env"        = local.env
    "${local.ns}/managed-by" = "terraform"
  }

  labels = local.component == null ? local.labels_base : merge(local.labels_base, {
    "${local.ns}/component" = local.component
  })

  # Tags: AWS-ready (map[string]string), but intentionally generic.
  tags_base = {
    "${local.ns}:project"    = local.project
    "${local.ns}:env"        = local.env
    "${local.ns}:managed-by" = "terraform"
  }

  tags_with_component = local.component == null ? local.tags_base : merge(local.tags_base, {
    "${local.ns}:component" = local.component
  })

  tags_with_owner = var.owner == null ? local.tags_with_component : merge(local.tags_with_component, {
    "owner" = trimspace(var.owner)
  })

  tags = merge(local.tags_with_owner, var.extra_tags)

  env_short = {
    local = "l"
    dev   = "d"
    prod  = "p"
  }[local.env]
}
