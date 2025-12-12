locals {
  env = "prod"
}

output "env" {
  value = local.env
}
