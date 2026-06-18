# Architecture

!!! note "Status: planned (Phase B)"
    Written before we build. This page will cover the three gates, what each enforces, the end-to-end request flow as defense in depth, and the homelab topology — with a diagram.

## Coming here

- The three gates and their enforcement responsibilities.
- End-to-end request flow (edge → API/AI/MCP gate → upstream).
- Defense-in-depth: how an attack blocked at one gate is still caught by the next.
- Homelab topology (cluster, ArgoCD, Traefik Hub, NVIDIA NIM endpoint).
