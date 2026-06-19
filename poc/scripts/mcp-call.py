#!/usr/bin/env python3
"""Call a tool on the e-commerce MCP server through the Traefik MCP Gateway.

  usage: mcp-call.py <jwt> <tool|--list> [json-args]
  e.g.   mcp-call.py "$TOKEN" --list
         mcp-call.py "$TOKEN" get_order '{"order_id":"88213"}'
         mcp-call.py "$TOKEN" reorder   '{"sku":"SKU-BLU-42","qty":50}'

Prints the tool result, or "DENIED/ERROR: ..." if the gateway (TBAC/JWT) rejects
the call.
"""
import sys, json, asyncio
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client

URL = "http://mcp.localhost/ecommerce-mcp/mcp"


async def main(token: str, tool: str, args: dict):
    headers = {"Authorization": f"Bearer {token}"}
    async with streamablehttp_client(URL, headers=headers) as (read, write, _):
        async with ClientSession(read, write) as session:
            await session.initialize()
            if tool == "--list":
                tools = await session.list_tools()
                print("allowed tools/list ->", [t.name for t in tools.tools])
                return
            result = await session.call_tool(tool, args)
            out = result.content[0].text if result.content else str(result)
            print(f"ALLOWED {tool} -> {out}")


def _flatten(exc):
    """Yield leaf exceptions, descending into ExceptionGroups."""
    if isinstance(exc, BaseExceptionGroup):
        for sub in exc.exceptions:
            yield from _flatten(sub)
    else:
        yield exc


if __name__ == "__main__":
    token, tool = sys.argv[1], sys.argv[2]
    args = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
    try:
        asyncio.run(main(token, tool, args))
    except BaseException as e:  # noqa: BLE001
        for leaf in _flatten(e):
            status = getattr(getattr(leaf, "response", None), "status_code", None)
            if status:
                print(f"DENIED {tool} -> HTTP {status} (blocked by gateway TBAC/JWT)")
                break
            msg = str(leaf)
            if msg and "TaskGroup" not in msg:
                print(f"DENIED {tool} -> {type(leaf).__name__}: {msg}")
                break
        else:
            print(f"DENIED {tool} -> blocked by gateway")
