#!/usr/bin/env bash
# Open the Grafana UI (admin/admin) at http://localhost:3000. Ctrl-C to stop.
set -euo pipefail
CTX="kind-triple-gate"
echo "→ http://localhost:3000   (user: admin / pass: admin)"
echo "  Dashboards → 'Traefik Triple Gate'"
kubectl --context "${CTX}" -n observability port-forward svc/grafana 3000:80
