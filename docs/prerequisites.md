# Prerequisites

This page is verified **live** on the homelab — every check below shows the command, the healthy output to expect, and how to fix it if missing. Reproduce it top to bottom and you'll have a working base for all three gates.

!!! info "Reference environment"
    macOS 26 on Apple Silicon (arm64), 12 cores / 36 GB RAM. Homebrew is the package manager. **No local GPU is required** for any default step.

## Local machine

### Summary

| Tool | Purpose | Verified version |
| --- | --- | --- |
| Docker (via Colima) | Container runtime under kind | 29.5.3 CLI / 29.5.2 server |
| kind | Single-node Kubernetes (no bundled ingress) | 0.32.0 |
| kubectl | Cluster CLI | v1.31.2 |
| Helm | Install Traefik Hub | v4.2.2 ⚠️ *(see note)* |
| argocd CLI | Drive GitOps reconciliation | v3.4.3 |
| git · curl · jq | VCS · exercise gates · parse JSON | 2.39.3 · 8.7.1 · 1.7.1 |

!!! warning "Helm 4 vs Helm 3"
    Homebrew currently installs **Helm 4**. Traefik Hub's charts are validated against Helm 3. Helm 4 is largely backward-compatible; if a chart misbehaves, install Helm 3 alongside it:
    ```bash
    brew install helm@3
    # then call it explicitly, e.g.
    /opt/homebrew/opt/helm@3/bin/helm version --short
    ```

### Container runtime — Colima + kind

We use **Colima** (free, open-source, Apple-Silicon-friendly) to provide a Docker-compatible daemon, and **kind** for the cluster. kind ships **no** ingress controller, so nothing competes with Traefik Hub — the cleanest base for this PoC. (If you prefer k3d, you must disable its bundled Traefik with `--k3s-arg "--disable=traefik@server:0"`.)

```bash
brew install colima docker kind helm argocd
colima start --cpu 4 --memory 8 --disk 60
```

Verify the daemon is reachable and Docker works end to end:

```bash
docker info --format 'Server {{.ServerVersion}} | {{.NCPU}} CPU | {{.MemTotal}} bytes RAM'
docker run --rm hello-world
```

**Healthy output:**

```text
Server 29.5.2 | 4 CPU | 8307101696 bytes RAM
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### kubectl, Helm, argocd, jq

```bash
kubectl version --client -o json | jq -r .clientVersion.gitVersion   # v1.31.2
helm version --short                                                 # v4.2.2+...
argocd version --client --short                                      # v3.4.3+...
jq --version                                                         # jq-1.7.1
```

If `kubectl` or `jq` are missing: `brew install kubectl jq`.

## SaaS & external dependencies

!!! note "Status: next up"
    Verified once tokens are provided. None require a GPU or a paid plan to start.

| Dependency | Purpose | How to verify | Status |
| --- | --- | --- | --- |
| **Traefik Hub trial token** | Register the gateway to the cluster (`helm upgrade`); must include **AI + MCP** entitlements | Connect the gateway, then test `hub.aigateway.enabled=true` | ⏳ |
| **NVIDIA hosted NIM** (`nvapi-` key) | LLM traffic **and** the safety guard — OpenAI-compatible, no GPU | `curl https://integrate.api.nvidia.com/v1/models` with the key | ⏳ |
| **Second LLM provider** (optional) | Failover demo | OpenAI key, or local Ollama at `:11434` | ⏳ |
| **MCP server** (`mcp-ecommerce-agent`) | Workload behind Gate 3 | Image/repo reachable | ⏳ |

!!! tip "Secrets hygiene"
    All tokens go in a gitignored `.env` (copy from `.env.example`) and are injected as Kubernetes Secrets by scripts in `poc/scripts/`. Nothing secret is ever committed, and this published site contains zero secrets.
