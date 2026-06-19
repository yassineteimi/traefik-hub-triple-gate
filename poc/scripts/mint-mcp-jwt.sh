#!/usr/bin/env bash
# Mint an HS256 JWT for the MCP Gateway, carrying an `allowed_tools` claim that
# drives TBAC. Signed with JWT_SIGNING_SECRET (same secret as apps/jwt).
#   usage: ./poc/scripts/mint-mcp-jwt.sh <sub> <tool1,tool2,...>
#   e.g.   ./poc/scripts/mint-mcp-jwt.sh support get_order,list_inventory
#          ./poc/scripts/mint-mcp-jwt.sh ops get_order,list_inventory,reorder,approve_return
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -a; . "${HERE}/../../.env"; set +a
: "${JWT_SIGNING_SECRET:?JWT_SIGNING_SECRET missing in .env}"

SUB="${1:?usage: mint-mcp-jwt.sh <sub> <comma-separated-tools>}"
TOOLS="${2:?usage: mint-mcp-jwt.sh <sub> <comma-separated-tools>}"

python3 - "$SUB" "$TOOLS" "$JWT_SIGNING_SECRET" <<'PY'
import sys, time, json, hmac, hashlib, base64
sub, tools_csv, secret = sys.argv[1:4]
b64 = lambda b: base64.urlsafe_b64encode(b).rstrip(b"=")
now = int(time.time())
payload = {
    "sub": sub,
    "allowed_tools": [t.strip() for t in tools_csv.split(",") if t.strip()],
    "iat": now, "exp": now + 3600,
}
seg = b64(json.dumps({"alg":"HS256","typ":"JWT"},separators=(",",":")).encode()) + b"." + \
      b64(json.dumps(payload,separators=(",",":")).encode())
sig = hmac.new(secret.encode(), seg, hashlib.sha256).digest()
print((seg + b"." + b64(sig)).decode())
PY
