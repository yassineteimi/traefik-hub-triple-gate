#!/usr/bin/env bash
# Idempotent: read tokens from the gitignored .env and create them as Kubernetes
# Secrets. Nothing secret is ever printed or committed.
#
#   - traefik/traefik-hub-license : Traefik Hub token (consumed by the Hub install)
#   - apps/nvidia-nim             : NVIDIA NIM API key (consumed by Gate 2 AI Gateway)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${HERE}/../../.env"
CTX="kind-triple-gate"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "❌ ${ENV_FILE} not found. Copy .env.example to .env and fill it in." >&2
  exit 1
fi

# Load .env without echoing values.
set -a; . "${ENV_FILE}"; set +a

require() { # require VARNAME
  if [[ -z "${!1:-}" ]]; then echo "❌ ${1} is empty in .env" >&2; exit 1; fi
}
require TRAEFIK_HUB_TOKEN
require NVIDIA_API_KEY
require JWT_SIGNING_SECRET

ns() { kubectl --context "${CTX}" get ns "$1" >/dev/null 2>&1 || kubectl --context "${CTX}" create ns "$1"; }
ns traefik
ns apps

# Apply (create-or-update) without leaking the value into the process table is
# acceptable for a homelab; the value never touches git or stdout.
kubectl --context "${CTX}" -n traefik create secret generic traefik-hub-license \
  --from-literal=token="${TRAEFIK_HUB_TOKEN}" \
  --dry-run=client -o yaml | kubectl --context "${CTX}" apply -f - >/dev/null
echo "✅ secret traefik/traefik-hub-license set"

kubectl --context "${CTX}" -n apps create secret generic nvidia-nim \
  --from-literal=apiKey="${NVIDIA_API_KEY}" \
  --dry-run=client -o yaml | kubectl --context "${CTX}" apply -f - >/dev/null
echo "✅ secret apps/nvidia-nim set"

# Gate 1: HS256 signing secret for the JWT middleware (key 'signingSecret',
# referenced as urn:k8s:secret:jwt:signingSecret).
kubectl --context "${CTX}" -n apps create secret generic jwt \
  --from-literal=signingSecret="${JWT_SIGNING_SECRET}" \
  --dry-run=client -o yaml | kubectl --context "${CTX}" apply -f - >/dev/null
echo "✅ secret apps/jwt set"
