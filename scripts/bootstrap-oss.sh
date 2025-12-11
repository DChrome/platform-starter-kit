#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/github-common.sh"

detect_repo
ensure_gh_auth

echo "Applying COMMON production profile to $OWNER/$REPO (branch: $BRANCH)"
apply_common_protection
configure_merge_policy

echo "Applying OSS-specific settings..."

# Mark as template
run_gh_api \
  --method PATCH \
  "repos/$OWNER/$REPO" \
  -f is_template=true

# Verify presence of LICENSE, SECURITY.md, CONTRIBUTING.md and print warnings.

missing=()
[[ -f LICENSE ]] || missing+=("LICENSE")
[[ -f SECURITY.md ]] || missing+=("SECURITY.md")
[[ -f CONTRIBUTING.md ]] || missing+=("CONTRIBUTING.md")

if ((${#missing[@]} > 0)); then
  echo "Warning: missing recommended OSS files: ${missing[*]}"
fi

echo "OSS profile applied (plus warnings above if any)."
