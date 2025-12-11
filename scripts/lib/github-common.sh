#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-false}"

run_gh_api() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY-RUN] gh api $*"
  else
    gh api --silent "$@"
  fi
}

detect_repo() {
  local REMOTE_URL CLEAN_URL
  REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
  if [[ -z "$REMOTE_URL" ]]; then
    echo "Error: no origin remote."
    exit 1
  fi
  CLEAN_URL="${REMOTE_URL/git@github.com:/https://github.com/}"
  OWNER="$(echo "$CLEAN_URL" | sed -E 's#https://github.com/([^/]+)/([^\.]+)(\.git)?#\1#')"
  REPO="$(echo "$CLEAN_URL" | sed -E 's#https://github.com/([^/]+)/([^\.]+)(\.git)?#\2#')"

  BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)"
  if [[ -z "${BRANCH:-}" ]]; then
    if git show-ref --quiet refs/heads/main; then
      BRANCH="main"
    elif git show-ref --quiet refs/heads/master; then
      BRANCH="master"
    else
      echo "Error: cannot determine default branch."
      exit 1
    fi
  fi

  export OWNER REPO BRANCH
}

ensure_gh_auth() {
  if ! gh auth status >/dev/null 2>&1; then
    echo "Error: gh not authenticated. Run: gh auth login"
    exit 1
  fi
}

apply_common_protection() {
  run_gh_api \
    --method PUT \
    "repos/$OWNER/$REPO/branches/$BRANCH/protection" \
    --header "Accept: application/vnd.github+json" \
    --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "CI / terraform-fmt",
      "CI / terraform-validate",
      "CI / tflint"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": true
  },
  "required_conversation_resolution": true,
  "restrictions": null
}
EOF
}

configure_merge_policy() {
  # Example: allow only squash, disable rebase & merge commits
  run_gh_api \
    --method PATCH \
    "repos/$OWNER/$REPO" \
    -f allow_squash_merge=true \
    -f allow_merge_commit=false \
    -f allow_rebase_merge=false
}

