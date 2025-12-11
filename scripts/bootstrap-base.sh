#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/github-common.sh"

detect_repo
ensure_gh_auth

echo "Applying BASE production profile to $OWNER/$REPO (branch: $BRANCH)"
apply_common_protection
configure_merge_policy
echo "Done."

