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
    ```sh
    $ brew install helm@3
    # then call it explicitly, e.g.
    $ /opt/homebrew/opt/helm@3/bin/helm version --short
    ```

### Container runtime — Colima + kind

We use **Colima** (free, open-source, Apple-Silicon-friendly) to provide a Docker-compatible daemon, and **kind** for the cluster. kind ships **no** ingress controller, so nothing competes with Traefik Hub — the cleanest base for this PoC. (If you prefer k3d, you must disable its bundled Traefik with `--k3s-arg "--disable=traefik@server:0"`.)

```sh
$ brew install colima docker kind helm argocd
$ colima start --cpu 4 --memory 8 --disk 60
```

Verify the daemon is reachable and Docker works end to end:

```sh
$ docker info --format 'Server {{.ServerVersion}} | {{.NCPU}} CPU | {{.MemTotal}} bytes RAM'
$ docker run --rm hello-world
```

```text title="Expected output"
Server 29.5.2 | 4 CPU | 8307101696 bytes RAM
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### kubectl, Helm, argocd, jq

```sh
$ kubectl version --client -o json | jq -r .clientVersion.gitVersion   # v1.31.2
$ helm version --short                                                 # v4.2.2+...
$ argocd version --client --short                                      # v3.4.3+...
$ jq --version                                                         # jq-1.7.1
```

If `kubectl` or `jq` are missing: `$ brew install kubectl jq`.

## SaaS & external dependencies

All tokens go in a gitignored `.env` (copy from `.env.example`). The checks below read from that file and **never print the secret** — they assert behaviour, not values.

| Dependency | Purpose | Status |
| --- | --- | --- |
| **Traefik Hub trial token** | Register the gateway to the cluster (`helm upgrade`); needs **AI + MCP** entitlements | ✅ present · entitlement confirmed at gateway connect (M0) |
| **NVIDIA hosted NIM** (`nvapi-` key) | LLM traffic **and** the safety guard — OpenAI-compatible, no GPU | ✅ verified (auth + inference) |
| **Second LLM provider** (optional) | Failover demo | ⏳ deferred to M2 |
| **MCP server** (`mcp-ecommerce-agent`) | Workload behind Gate 3 | ✅ located locally |

### Verify the NVIDIA key (auth + inference)

```sh
$ set -a; . ./.env; set +a

# 1) Auth: list models (expect HTTP 200)
$ curl -s -o /dev/null -w '%{http_code}\n' \
    "$NVIDIA_API_BASE/models" -H "Authorization: Bearer $NVIDIA_API_KEY"

# 2) Inference entitlement: a real chat completion
$ curl -s "$NVIDIA_API_BASE/chat/completions" \
    -H "Authorization: Bearer $NVIDIA_API_KEY" -H "Content-Type: application/json" \
    -d '{"model":"meta/llama-3.1-8b-instruct","messages":[{"role":"user","content":"Reply with exactly: GATE2_OK"}],"max_tokens":16,"temperature":0}' \
    | jq -r .choices[0].message.content
```

```text title="Expected output"
200
GATE2_OK
```

### Choosing the LLM Guard model (a real Phase A finding)

Traefik Hub's [LLM Guard](https://doc.traefik.io/traefik-hub/ai-gateway/middlewares/llm-guard) blocks on a text condition over the guard model's reply (e.g. `Contains("unsafe")`), so the guard must return a **parseable verdict**. We tested two NVIDIA safety models against the same prompts:

| Model | Reply to a harmful prompt | Fits `Contains("unsafe")`? |
| --- | --- | --- |
| `nvidia/nemotron-content-safety-reasoning-4b` | Prose refusal ("I cannot and will not…") | ❌ no verdict token → false negative |
| `nvidia/llama-3.1-nemoguard-8b-content-safety` | `{"User Safety": "unsafe", "Safety Categories": "…"}` | ✅ deterministic |

**Decision:** use **`nvidia/llama-3.1-nemoguard-8b-content-safety`** for the guard — the same model in Traefik's [official NVIDIA NIMs guide](https://doc.traefik.io/traefik-hub/ai-gateway/guides/nvidia-nims-integration). The reasoning model is a *safety-aware chat model*, not a classifier. Recorded in `.env` as `NVIDIA_GUARD_MODEL`.

!!! tip "Secrets hygiene"
    Tokens are injected as Kubernetes Secrets by scripts in `poc/scripts/`. Nothing secret is committed, and this published site contains zero secrets.
