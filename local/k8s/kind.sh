#!/usr/bin/env bash
set -euo pipefail

# Local kind cluster lifecycle helper.
#
# Usage:
#   ./kind.sh create
#   ./kind.sh status
#   ./kind.sh delete

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLUSTER_NAME="psk-local"
KIND_CONFIG="$SCRIPT_DIR/kind-config.yaml"

function die() {
  echo "[ERROR] $*" >&2
  exit 1
}

function need_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "Missing required command: $cmd"
}

function ensure_prereqs() {
  need_cmd docker
  need_cmd kind
  need_cmd kubectl

  # kind shells out to Docker; validate the daemon is reachable.
  if ! docker info >/dev/null 2>&1; then
    cat >&2 <<'EOF'
[ERROR] Docker is installed but the Docker daemon is not reachable.

Common fixes:
  - Start Docker Desktop and wait until it finishes starting.
  - If your Docker socket is non-default, ensure DOCKER_HOST is set correctly.

Tip:
  docker info
EOF
    exit 1
  fi
}

function cluster_exists() {
  kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"
}

function create_cluster() {
  ensure_prereqs

  if cluster_exists; then
    echo "[OK] kind cluster already exists: $CLUSTER_NAME"
    return 0
  fi

  [[ -f "$KIND_CONFIG" ]] || die "kind config not found: $KIND_CONFIG"

  echo "[RUN] Creating kind cluster: $CLUSTER_NAME"
  kind create cluster --name "$CLUSTER_NAME" --config "$KIND_CONFIG"

  echo "[RUN] Verifying cluster access"
  kubectl cluster-info
  kubectl get nodes -o wide

  echo "[OK] Cluster created: $CLUSTER_NAME"
}

function delete_cluster() {
  ensure_prereqs

  if ! cluster_exists; then
    echo "[OK] kind cluster not present: $CLUSTER_NAME"
    return 0
  fi

  echo "[RUN] Deleting kind cluster: $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME"
  echo "[OK] Cluster deleted: $CLUSTER_NAME"
}

function status() {
  ensure_prereqs

  echo "[INFO] kind clusters:"
  kind get clusters || true
  echo ""

  if ! cluster_exists; then
    echo "[INFO] $CLUSTER_NAME: not present"
    return 0
  fi

  echo "[INFO] $CLUSTER_NAME nodes:"
  kubectl get nodes -o wide
}

function usage() {
  cat <<EOF
Usage: ./kind.sh <command>

Commands:
  create   Create the local kind cluster ($CLUSTER_NAME)
  status   Show cluster status
  delete   Delete the local kind cluster ($CLUSTER_NAME)
EOF
}

cmd="${1:-}"
case "$cmd" in
  create) create_cluster ;;
  status) status ;;
  delete) delete_cluster ;;
  -h|--help|help|"") usage ;;
  *)
    usage
    die "Unknown command: $cmd"
    ;;
esac
