#!/usr/bin/env bash
# Wrapper for the MCP demo client. The client needs the `mcp` SDK (Python 3.10+),
# which macOS's system python3 (3.9) lacks — so we keep a dedicated venv and
# bootstrap it on first run. Then: ./poc/scripts/mcp-call.sh <jwt> <tool> '<json>'
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${HERE}/../.." && pwd)"
VENV="${ROOT}/.venv-mcp"

if [[ ! -x "${VENV}/bin/python" ]]; then
  PY=""
  for cand in python3.13 python3.12 python3.11 python3.10; do
    command -v "${cand}" >/dev/null 2>&1 && { PY="${cand}"; break; }
  done
  [[ -z "${PY}" ]] && { echo "❌ need Python 3.10+ for the mcp client (brew install python@3.12)" >&2; exit 1; }
  echo "⚙️  bootstrapping ${VENV} with ${PY} + mcp..." >&2
  "${PY}" -m venv "${VENV}"
  "${VENV}/bin/pip" install -q --upgrade pip >/dev/null 2>&1 || true
  "${VENV}/bin/pip" install -q mcp==1.28.0
fi

exec "${VENV}/bin/python" "${HERE}/mcp-call.py" "$@"
