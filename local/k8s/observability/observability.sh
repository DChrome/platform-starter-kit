#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="monitoring"

# Pin versions explicitly (local bootstrap must be reproducible)
PROMETHEUS_IMAGE="prom/prometheus:v3.8.0"
GRAFANA_IMAGE="grafana/grafana:12.3.0"
KSM_IMAGE="registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0"

INSTALL_YAML="$SCRIPT_DIR/install.yaml"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  install     Install Prometheus + Grafana + kube-state-metrics into the local cluster
  status      Show basic health/status signals
  uninstall   Remove observability stack (including namespace)

Notes:
  - This script assumes kubectl is configured for the target cluster.
  - Manifests are vendored in: install.yaml
EOF
}

require_kubectl() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "[ERROR] kubectl not found in PATH" >&2
    exit 1
  fi
}

apply() {
  kubectl apply -f "$INSTALL_YAML"
}

wait_ready() {
  kubectl -n "$NAMESPACE" rollout status deploy/kube-state-metrics --timeout=180s
  kubectl -n "$NAMESPACE" rollout status deploy/prometheus --timeout=180s
  kubectl -n "$NAMESPACE" rollout status deploy/grafana --timeout=180s
}

cmd_install() {
  require_kubectl

  # Inject pinned image versions into the vendored manifest (small, explicit mutation).
  # This keeps version pins in one obvious place (top of this script) without duplicating large YAML.
  #
  # We intentionally avoid templating systems here.
  tmp="$(mktemp)"
  sed \
    -e "s|__PROMETHEUS_IMAGE__|$PROMETHEUS_IMAGE|g" \
    -e "s|__GRAFANA_IMAGE__|$GRAFANA_IMAGE|g" \
    -e "s|__KSM_IMAGE__|$KSM_IMAGE|g" \
    "$INSTALL_YAML" > "$tmp"

  kubectl apply -f "$tmp"
  rm -f "$tmp"

  wait_ready

  echo
  echo "[OK] Installed. Next steps:"
  echo "  Grafana:   kubectl -n $NAMESPACE port-forward svc/grafana 3000:80"
  echo "  Prometheus: kubectl -n $NAMESPACE port-forward svc/prometheus 9090:9090"
}

cmd_status() {
  require_kubectl

  echo "Namespace: $NAMESPACE"
  kubectl get ns "$NAMESPACE" || true
  echo

  kubectl -n "$NAMESPACE" get deploy,po,svc -o wide
}

cmd_uninstall() {
  require_kubectl

  # Best-effort, idempotent cleanup.
  kubectl delete ns "$NAMESPACE" --ignore-not-found
}

main() {
  cmd="${1:-}"
  case "$cmd" in
    install)   cmd_install ;;
    status)    cmd_status ;;
    uninstall) cmd_uninstall ;;
    -h|--help|help|"") usage ; exit 0 ;;
    *)
      echo "[ERROR] unknown command: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
