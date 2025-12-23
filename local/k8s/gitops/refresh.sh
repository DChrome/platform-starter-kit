#!/usr/bin/env bash
set -euo pipefail

echo "Forcing ArgoCD hard refresh for root-local..."
kubectl -n argocd annotate application root-local \
  argocd.argoproj.io/refresh=hard --overwrite

echo "Done."
