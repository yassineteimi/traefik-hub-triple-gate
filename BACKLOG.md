# Backlog: v2 ideas

Deferred enhancements to tackle after the v1 tutorial (the three gates + unified demo + observability) is complete.

## Reproducibility: one-click "Open in Cloud Shell" + small GKE

Add an **Open in Google Cloud Shell** button (deep link that clones the repo and opens a `tutorial.md` guided pane) so a reader gets a predictable Linux environment (bash 5, Docker, kubectl, helm, gcloud preinstalled), no macOS/Homebrew/Colima variance.

- **Why not kind-in-Cloud-Shell:** Cloud Shell is e2-small (2 GB RAM; "boost" = e2-medium, 4 GB). The full stack (ArgoCD ~1 GB + Prometheus + Grafana + OTel) won't fit. A trimmed "gates-lite" profile might fit boosted, but it's tight and drops observability.
- **Chosen path: deploy to a small GKE cluster from Cloud Shell** (mirrors the GoogleCloudPlatform/race-condition pattern: deploy to real managed services, not a local cluster). Real resources, predictable, full stack incl. dashboards.
- **Cost / credits (researched 2026-06-20):**
  - **GKE free tier**: $74.40/month credit covers the management fee for **one** zonal/Autopilot cluster (not nodes/LB/egress).
  - **$300 free trial** (90 days, new GCP account) easily covers an intermittent demo cluster. Best fit if not already used.
  - **Innovators Plus** ($299/yr): ~$1,000 credits + a certification voucher + Skills Boost (worth considering anyway as a trainer).
  - **Google for Startups**: $2k–$350k but needs startup eligibility (likely N/A).
  - Practical cost if spun up and torn down per demo: roughly a couple of dollars/day for a small node pool + LoadBalancer; near-zero when torn down.
- **Deliverables:** `tutorial.md`, the button + SVG in README, a `cloudshell/up.sh` (gcloud create cluster -> install ArgoCD + Traefik Hub + gates + observability), a `cloudshell/down.sh` teardown that deletes the cluster, and clear cost/teardown messaging in the tutorial. Reader still supplies the Traefik Hub + NVIDIA tokens (tutorial prompts for them).

## Air-gapped reference variant

A sovereign/air-gapped profile: Traefik Hub in **offline mode** (`hub.offline`, validate it preserves API + AI + MCP features), **self-hosted NVIDIA NIMs** (`nvcr.io/nim/...`) on on-prem/OpenShift GPUs instead of the hosted endpoint, images/models mirrored into an internal registry. Same gates, same GitOps and TBAC; only the endpoints move inside the perimeter. High value for the French regulated/SecNumCloud market (see the Evaluation page).

## Gate 2: AI Gateway

- **Semantic cache.** Serve repeated/similar prompts from cache without an LLM round-trip (latency + cost win). Traefik Hub AI Gateway semantic-cache middleware.
- **Token rate-limit / quota.** Per-identity token budgets for cost governance.
- **Automatic provider failover.** Route to a second LLM (OpenAI or local Ollama) when the primary NVIDIA NIM fails. `.env` already has placeholders `OPENAI_API_KEY` / `OLLAMA_API_BASE`.

  _Deferred from M2 (v1 ships routing + Content Guard + LLM Guard); finish in v2._

## Gate 1: API Gateway

- **API versioning + Developer Portal.** Demonstrate Traefik Hub's API management layer: versioned APIs (e.g. `v1`/`v2` of the sample API), an **API Portal** for developer self-service (browse APIs, generate tokens/keys), and how a publisher promotes a new version, all **GitOps-managed** (declared in `poc/`, reconciled by ArgoCD), consistent with the rest of the PoC. Requires `hub.apimanagement.enabled=true`.
  _Suggested by the author during M1; keep for v2._
