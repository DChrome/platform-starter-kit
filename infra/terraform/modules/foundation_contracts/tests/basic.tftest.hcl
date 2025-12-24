variables {
  namespace = "psk"
}

run "prefix_without_component" {
  command = plan
  plan_options {
    refresh = false
  }

  variables {
    project = "psk"
    env     = "dev"
  }

  assert {
    condition     = output.name_prefix == "psk-dev"
    error_message = "expected name_prefix to be 'psk-dev'"
  }

  assert {
    condition     = output.tags["psk:project"] == "psk"
    error_message = "expected tag psk:project to be 'psk'"
  }

  assert {
    condition     = output.tags["psk:env"] == "dev"
    error_message = "expected tag psk:env to be 'dev'"
  }

  assert {
    condition     = output.tags["psk:managed-by"] == "terraform"
    error_message = "expected tag psk:managed-by to be 'terraform'"
  }

  assert {
    condition     = output.env_short == "d"
    error_message = "expected env_short to be 'd'"
  }
}

run "prefix_with_component_and_owner_and_extra_tags" {
  command = plan
  plan_options {
    refresh = false
  }

  variables {
    project   = "psk"
    env       = "prod"
    component = "network"
    owner     = "platform"
    extra_tags = {
      "cost-center" = "000"
      "psk:env"     = "prod"
    }
  }

  assert {
    condition     = output.name_prefix == "psk-prod-network"
    error_message = "expected name_prefix to be 'psk-prod-network'"
  }

  assert {
    condition     = output.tags["psk:component"] == "network"
    error_message = "expected tag psk:component to be 'network'"
  }

  assert {
    condition     = output.tags["owner"] == "platform"
    error_message = "expected tag owner to be 'platform'"
  }

  assert {
    condition     = output.tags["cost-center"] == "000"
    error_message = "expected tag cost-center to be '000'"
  }

  assert {
    condition     = output.env_short == "p"
    error_message = "expected env_short to be 'p'"
  }
}

run "invalid_env_rejected" {
  command = plan
  plan_options {
    refresh = false
  }

  variables {
    project = "psk"
    env     = "stage"
  }

  expect_failures = [var.env]
}

run "invalid_project_rejected" {
  command = plan
  plan_options {
    refresh = false
  }

  variables {
    project = "PSK Project"
    env     = "dev"
  }

  expect_failures = [var.project]
}
