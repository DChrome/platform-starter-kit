#!/usr/bin/env bash
set -euo pipefail

# Function to kill all background jobs.
# This function makes the script more robust by ensuring that all port-forwards are stopped when the script exits,
# even though, in normal foreground execution, the jobs would be killed automatically when the script exits.
cleanup() {
    echo "Stopping port-forwards..."
    # 'jobs -p' lists the PIDs of all background processes started by this shell
    # shellcheck disable=SC2046
    kill $(jobs -p) 2>/dev/null || true
    exit
}

# Trap EXIT and run the cleanup function
trap cleanup EXIT

echo "Forwarding ArgoCD -> http://localhost:8080"
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
echo "=========="
echo "Get the ArgoCD admin password by running:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
echo "=========="

echo "Forwarding Grafana -> http://localhost:3000"
kubectl -n monitoring port-forward svc/grafana 3000:80 &

echo "Forwarding Prometheus -> http://localhost:9090"
kubectl -n monitoring port-forward svc/prometheus-server 9090:80 &

wait
