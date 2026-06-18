#!/usr/bin/env bash
# Idempotent: create the kind cluster for the Triple Gate PoC if it doesn't exist.
set -euo pipefail

CLUSTER="triple-gate"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${HERE}/../cluster/kind-config.yaml"

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER}"; then
  echo "✅ kind cluster '${CLUSTER}' already exists — skipping create."
else
  echo "🚀 Creating kind cluster '${CLUSTER}'..."
  kind create cluster --config "${CONFIG}" --wait 90s
fi

echo "🔎 Cluster status:"
kubectl --context "kind-${CLUSTER}" get nodes
