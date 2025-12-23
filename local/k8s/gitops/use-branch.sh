#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-$(git rev-parse --abbrev-ref HEAD)}"

ARGO_NS="argocd"
ROOT_APP="root-local"
REPO_URL="https://github.com/DChrome/platform-starter-kit.git"

# Check for required tools
if ! command -v yq &> /dev/null; then
    echo "[ERROR] 'yq' is not installed. Please install it (https://github.com/mikefarah/yq?tab=readme-ov-file#install)."
    exit 1
fi

# Discover child apps from YAML files under gitops/envs/local/argocd/apps
CHILD_APPS=()
APPS_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo .)/gitops/envs/local/argocd/apps"

if [ ! -d "$APPS_DIR" ]; then
    echo "[ERROR] Applications directory not found: $APPS_DIR"
    exit 1
fi

while IFS= read -r name; do
    CHILD_APPS+=("$name")
done < <(find "$APPS_DIR" -type f \( -name "*.yaml" -o -name "*.yml" \) \
        -exec yq -rN 'select(.kind == "Application") | .metadata.name | select(. != null)' {} +)

if [ "${#CHILD_APPS[@]}" -eq 0 ]; then
    echo "[ERROR] Failed to discover child applications from $APPS_DIR, exiting."
    exit 1
else
    echo "Discovered child applications:"
    printf "* %s\n" "${CHILD_APPS[@]}"
fi

# Patch root application and child applications to use the specified branch
echo "Using branch: $BRANCH"
echo

echo "Patching root application ($ROOT_APP)..."
kubectl -n "$ARGO_NS" patch application "$ROOT_APP" --type merge -p "{
  \"spec\": {
    \"source\": {
      \"targetRevision\": \"$BRANCH\"
    }
  }
}"

echo "Patching child applications..."
for app in "${CHILD_APPS[@]}"; do
  echo "  - $app"
  INDEX=$(kubectl get app "$app" -n "$ARGO_NS" -o json | jq ".spec.sources | map(.repoURL == \"$REPO_URL\") | index(true)")

  # Check if index was found to avoid patching /spec/sources/null
  if [ "$INDEX" != "null" ]; then
    kubectl -n "$ARGO_NS" patch application "$app" --type json -p "[
      {
        \"op\": \"replace\",
        \"path\": \"/spec/sources/$INDEX/targetRevision\",
        \"value\": \"$BRANCH\"
      }
    ]"
  else
    echo "[Error] Repo URL $REPO_URL not found in $app sources."
    exit 1
  fi
done

echo
echo "Forcing ArgoCD hard refresh..."
kubectl -n "$ARGO_NS" annotate application "$ROOT_APP" argocd.argoproj.io/refresh=hard --overwrite

echo
echo "[OK] Done. Make sure that your branch '$BRANCH' has been pushed to the remote repository."
