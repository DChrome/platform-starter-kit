#!/usr/bin/env bash
set -euo pipefail

echo "== ArgoCD Applications =="
kubectl -n argocd get applications

echo
echo "== Monitoring Pods =="
kubectl -n monitoring get pods

echo
echo "== Monitoring Services =="
kubectl -n monitoring get svc
