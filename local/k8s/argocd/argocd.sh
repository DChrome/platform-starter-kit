#!/usr/bin/env bash
set -euo pipefail

# Argo CD local bootstrap helper (pinned to v3.2.1 via vendored manifest).
#
# Usage:
#   ./local/k8s/argocd/argocd.sh install
#   ./local/k8s/argocd/argocd.sh status
#   ./local/k8s/argocd/argocd.sh uninstall
#
# Notes:
# - This is a day-0 bootstrap step. We install Argo CD imperatively from a vendored manifest.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="argocd"
MANIFEST="$SCRIPT_DIR/install.yaml"

die() { echo "[ERROR] $*" >&2; exit 1; }

function need_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "Missing required command: $cmd"
}

ensure_cluster_reachable() {
  # Fail fast with a clear message if kube context isn't usable.
  kubectl version --client >/dev/null 2>&1 || die "kubectl is not usable"
  kubectl cluster-info >/dev/null 2>&1 || die "kubeconfig context is not pointing to a reachable cluster (did you run ./local/k8s/kind.sh create?)"
}

ensure_namespace() {
  if ! kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    echo "[RUN] Creating namespace '$NAMESPACE'..."
    kubectl create namespace "$NAMESPACE" >/dev/null
  fi
}

wait_ready() {
  echo "Waiting for Argo CD deployments to become Available..."
  kubectl -n "$NAMESPACE" wait --for=condition=Available deploy --all --timeout=10m >/dev/null

  echo "Waiting for Argo CD pods to become Ready..."
  # Some pods might take longer on first pull.
  kubectl -n "$NAMESPACE" wait --for=condition=Ready pod --all --timeout=10m >/dev/null
}

cmd_install() {
  need_cmd kubectl
  ensure_cluster_reachable
  [[ -f "$MANIFEST" ]] || die "Manifest not found: $MANIFEST"

  ensure_namespace

  echo "[RUN] Applying Argo CD manifest (vendored, pinned)..."
  kubectl -n "$NAMESPACE" apply -f "$MANIFEST" >/dev/null

  wait_ready

  echo
  echo "[OK] Argo CD installed."
  echo "Next:"
  echo "  kubectl -n $NAMESPACE port-forward svc/argocd-server 8080:443"
  echo "  kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
}

cmd_status() {
  need_cmd kubectl
  ensure_cluster_reachable

  if ! kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' not found. Argo CD is not installed."
    exit 0
  fi

  echo "Namespace: $NAMESPACE"
  kubectl -n "$NAMESPACE" get deploy,sts,svc,pods -o wide
  echo
  echo "Tip: UI port-forward"
  echo "  kubectl -n $NAMESPACE port-forward svc/argocd-server 8080:443"
}

cmd_uninstall() {
  need_cmd kubectl
  ensure_cluster_reachable

  if ! kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' not found. Nothing to uninstall."
    exit 0
  fi

  echo "[RUN] Deleting namespace '$NAMESPACE' (this removes all Argo CD resources)..."
  kubectl delete namespace "$NAMESPACE" --wait=true >/dev/null
  echo "[OK] Argo CD uninstalled."
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    install)   cmd_install ;;
    status)    cmd_status ;;
    uninstall) cmd_uninstall ;;
    *) die "Usage: $0 {install|status|uninstall}" ;;
  esac
}

main "$@"
