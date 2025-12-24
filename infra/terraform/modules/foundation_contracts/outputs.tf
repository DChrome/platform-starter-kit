output "id" {
  description = "Canonical identifiers for this context."
  value       = local.id
}

output "name_prefix" {
  description = "Canonical prefix for resource names (project-env[-component])."
  value       = local.name_prefix
}

output "tags" {
  description = "Canonical tag set, merged with extra_tags."
  value       = local.tags
}

output "labels" {
  description = "Provider-agnostic labels (mirrors K8s-style labeling)."
  value       = local.labels
}

output "env_short" {
  description = "Environment shorthand (l/d/p)."
  value       = local.env_short
}
