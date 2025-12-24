#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
tf_root="${repo_root}/infra/terraform"

if [[ ! -d "${tf_root}" ]]; then
  echo "[ERROR] Failed to find terraform root. Layout contract violated."
  exit 1
fi

echo "[terraform] fmt -check (recursive): ${tf_root}"
terraform -chdir="${tf_root}" fmt -check -recursive

roots=(
  "${tf_root}/accounts/dev"
  "${tf_root}/accounts/prod"
)

for root in "${roots[@]}"; do
  echo
  echo "[terraform] root: ${root}"
  terraform -chdir="${root}" init -backend=false -upgrade=false
  terraform -chdir="${root}" fmt -check
  terraform -chdir="${root}" validate
done

echo
echo "[terraform] module tests: foundation_contracts"
terraform -chdir="${tf_root}/modules/foundation_contracts" init -backend=false -upgrade=false
terraform -chdir="${tf_root}/modules/foundation_contracts" test

echo
echo "[terraform] OK"
