#!/usr/bin/env bash
# Idempotent: install/upgrade ArgoCD via Helm (pinned chart) into the argocd ns.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES="${HERE}/../argocd/values.yaml"
CTX="kind-triple-gate"
CHART_VERSION="9.5.21"   # appVersion v3.4.3

helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
helm repo update argo >/dev/null

echo "🚀 Installing/upgrading ArgoCD (chart ${CHART_VERSION})..."
helm --kube-context "${CTX}" upgrade --install argocd argo/argo-cd \
  --version "${CHART_VERSION}" \
  --namespace argocd --create-namespace \
  -f "${VALUES}" \
  --wait --timeout 5m

echo "🔎 ArgoCD pods:"
kubectl --context "${CTX}" -n argocd get pods
