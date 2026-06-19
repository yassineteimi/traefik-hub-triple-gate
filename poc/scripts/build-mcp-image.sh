#!/usr/bin/env bash
# Build the e-commerce MCP server image and load it into the kind cluster.
# kind has no registry, so we side-load the image onto the node.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CTX_CLUSTER="triple-gate"
IMAGE="ecommerce-mcp:0.1.0"

echo "🐳 Building ${IMAGE}..."
docker build -t "${IMAGE}" "${HERE}/../gate3-mcp/server"

echo "📦 Loading ${IMAGE} into kind cluster '${CTX_CLUSTER}'..."
kind load docker-image "${IMAGE}" --name "${CTX_CLUSTER}"

echo "✅ Done. Restart the Deployment to pick up a rebuilt image:"
echo "   kubectl -n apps rollout restart deploy/ecommerce-mcp"
