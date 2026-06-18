#!/usr/bin/env bash
# Mint a short-lived HS256 JWT signed with JWT_SIGNING_SECRET from .env, so we can
# exercise Gate 1. Prints only the token to stdout (usable as a Bearer header).
#   usage: ./poc/scripts/mint-jwt.sh [sub] [scope]
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -a; . "${HERE}/../../.env"; set +a
: "${JWT_SIGNING_SECRET:?JWT_SIGNING_SECRET missing in .env}"

SUB="${1:-alice}"
SCOPE="${2:-api:read}"
ISS="${JWT_ISSUER:-https://triple-gate.local/issuer}"
AUD="${JWT_AUDIENCE:-triple-gate-poc}"

python3 - "$SUB" "$SCOPE" "$ISS" "$AUD" "$JWT_SIGNING_SECRET" <<'PY'
import sys, time, json, hmac, hashlib, base64
sub, scope, iss, aud, secret = sys.argv[1:6]
b64 = lambda b: base64.urlsafe_b64encode(b).rstrip(b"=")
now = int(time.time())
header  = {"alg": "HS256", "typ": "JWT"}
payload = {"sub": sub, "scope": scope, "iss": iss, "aud": aud,
           "iat": now, "exp": now + 3600}
seg = b64(json.dumps(header,separators=(",",":")).encode()) + b"." + \
      b64(json.dumps(payload,separators=(",",":")).encode())
sig = hmac.new(secret.encode(), seg, hashlib.sha256).digest()
print((seg + b"." + b64(sig)).decode())
PY
