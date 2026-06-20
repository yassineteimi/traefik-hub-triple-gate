"""Minimal e-commerce MCP server (Streamable HTTP) for the Triple Gate PoC.

Embodies the mcp-ecommerce-agent design: a few business tools over MCP, with a
clear read-vs-write split so the MCP Gateway's TBAC can allow/deny per identity.

Tools:
  - get_order(order_id)      [read]   - order status
  - list_inventory()        [read]   - stock levels
  - reorder(sku, qty)       [write]  - restock (privileged)
  - approve_return(rma_id)  [write]  - approve a return (privileged)
"""
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("ecommerce", host="0.0.0.0", port=8000)

# --- fake systems of record -------------------------------------------------
_ORDERS = {
    "88213": {"status": "delayed", "reason": "driver called in sick", "eta": "2026-06-21"},
    "88214": {"status": "shipped", "carrier": "DHL", "eta": "2026-06-20"},
}
_INVENTORY = {"SKU-RED-42": 12, "SKU-BLU-42": 0, "SKU-GRN-42": 134}


@mcp.tool()
def get_order(order_id: str) -> dict:
    """Look up the status of a customer order by its ID."""
    return _ORDERS.get(order_id, {"error": f"order {order_id} not found"})


@mcp.tool()
def list_inventory() -> dict:
    """List current stock levels per SKU."""
    return {"inventory": _INVENTORY}


@mcp.tool()
def reorder(sku: str, qty: int) -> dict:
    """Place a restock order for a SKU (privileged: ops only)."""
    _INVENTORY[sku] = _INVENTORY.get(sku, 0) + qty
    return {"ok": True, "sku": sku, "new_level": _INVENTORY[sku]}


@mcp.tool()
def approve_return(rma_id: str) -> dict:
    """Approve a customer return/RMA (privileged: ops only)."""
    return {"ok": True, "rma_id": rma_id, "status": "approved"}


if __name__ == "__main__":
    mcp.run(transport="streamable-http")
