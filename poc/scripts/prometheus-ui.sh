#!/usr/bin/env bash
# Port-forward Prometheus to http://localhost:9090 (UI + HTTP API). Ctrl-C to stop.
# Needed before any `curl http://localhost:9090/api/...` query — Prometheus runs
# inside the cluster and is not otherwise exposed on the host.
set -euo pipefail
CTX="kind-triple-gate"
echo "→ http://localhost:9090   (Prometheus UI + /api/v1/query)"
kubectl --context "${CTX}" -n observability port-forward svc/observability-prometheus-server 9090:80
