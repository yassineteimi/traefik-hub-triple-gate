#!/usr/bin/env bash
# Open the ArgoCD UI: prints the admin password and port-forwards the server.
# Server runs in insecure mode, so the UI is plain HTTP at http://localhost:8080
# (username: admin). Ctrl-C to stop.
set -euo pipefail
CTX="kind-triple-gate"

echo "ArgoCD admin password:"
kubectl --context "${CTX}" -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
echo
echo "→ open http://localhost:8080  (user: admin)"
kubectl --context "${CTX}" -n argocd port-forward svc/argocd-server 8080:80
