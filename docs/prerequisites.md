# Prerequisites

!!! note "Status: in progress (Phase A)"
    This page is filled in live as we verify each prerequisite on the homelab. Each check below will get its command, the expected healthy output, and how to fix it if missing.

## Local machine

| Tool | Purpose | Verified |
| --- | --- | --- |
| Docker | Container runtime for the local cluster | ⏳ |
| kind *or* k3d | Single-node Kubernetes (disable built-in Traefik if k3d/k3s) | ⏳ |
| kubectl | Cluster CLI | ⏳ |
| Helm 3 | Install Traefik Hub (OSS→Hub upgrade) | ⏳ |
| git | Version control / GitOps source | ⏳ |
| argocd CLI | Drive ArgoCD | ⏳ |
| curl + jq | Exercise and inspect the gates | ⏳ |

## SaaS & external dependencies

| Dependency | Purpose | Verified |
| --- | --- | --- |
| Traefik Hub trial token | Register the gateway; needs AI + MCP entitlements | ⏳ |
| NVIDIA hosted NIM (`nvapi-` key) | LLM traffic + safety guard (OpenAI-compatible, no GPU) | ⏳ |
| Second LLM provider (optional) | Failover demo (OpenAI or local Ollama) | ⏳ |
| MCP server (`mcp-ecommerce-agent`) | Workload behind Gate 3 | ⏳ |
