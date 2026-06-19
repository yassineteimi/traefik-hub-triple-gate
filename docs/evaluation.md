# Evaluation Notes

A practitioner's assessment after building the Triple Gate end-to-end, written
through the lens that matters for my market: **French and European regulated
institutions** — banks, insurers, public sector, health — and the stricter subset
that runs **air-gapped or sovereignty-constrained** estates. The benchmark is not
"does it work" (it does) but "would I put this in front of a regulated buyer, and
where would IBM API Connect or WSO2 still win".

## What impressed me

- **CRD-native, GitOps-first by construction.** Every gate in this PoC is a YAML
  object reconciled by ArgoCD — auth, rate limits, AI guards, and **tool-level
  authorization** are all the same declarative substrate. The OSS→Hub upgrade was
  literally a git commit. For a regulated shop, that means **change is auditable by
  default**: every policy change is a reviewed, signed, revertible commit, not a
  click in a console.
- **One control plane for three problem classes.** API auth, LLM governance
  (PII/safety/cost), and MCP **agent** authorization sit behind one gateway with one
  policy model. That consolidation is rare and strategically interesting as agentic
  systems arrive.
- **Defense in depth that actually composes.** A prompt-injection that subverts the
  agent's reasoning is still stopped by TBAC at the tool boundary. "A compromised
  agent is not a compromised system" is a message that lands with a CISO.
- **Standards-aligned telemetry.** AI metrics follow the OpenTelemetry **GenAI
  semantic conventions** (token usage, model, cost), so observability is portable,
  not a proprietary lock-in.

## What I'd flag

- **Observability needs assembly.** Request metrics are on Prometheus, but the
  AI/MCP metrics are **OTLP-only** — you must run a collector to land them in
  Prometheus. Content Guard has no first-class counter (blocks only show as `403`),
  and a denied MCP tool call doesn't populate `mcp_tool_name`. The signals are
  excellent; the **out-of-the-box dashboarding is not** — budget for it.
- **The SaaS control-plane dependency is the headline risk for my market** (see
  below). During the PoC the agent logged `Unable to ping platform api.traefik.io`
  — a reminder that the gateway data plane is self-hosted but the **control plane
  phones home** by default.
- **Trial/entitlement coupling.** AI and MCP gateways require license entitlements;
  fine for a PoC, but procurement and air-gap teams will want the offline licensing
  story in writing.

## GitOps & operating model vs IBM API Connect and WSO2

Comparing against the two platforms I know hands-on:

| Dimension | **Traefik Hub** | **IBM API Connect** | **WSO2 API Manager** |
| --- | --- | --- | --- |
| Config model | **Kubernetes CRDs**, GitOps-native | Mgmt UI + CLI; gateway = DataPower/Gateway; GitOps is bolted on | Publisher UI + APICTL; config-as-code possible, not idiomatic |
| Footprint | Light (one proxy + agent) | Heavy (Mgmt, Portal, Analytics, Gateway/DataPower) | Medium-heavy (APIM, KM, optional analytics) |
| AI / LLM gateway | **First-class** (guards, token cost, semantic cache) | Emerging | Emerging (AI gateway features maturing) |
| MCP / agent authz | **First-class (TBAC)** | Not yet | Not yet |
| Air-gap maturity | Newer; offline mode exists, **must be validated** | **Battle-tested** in regulated/air-gapped banks | Strong; OSS core deployable fully offline |
| Regulated-bank pedigree | Emerging | **Deep** (incumbent in FR banks/insurers) | Established, esp. where OSS/sovereignty preferred |

**Read:** Traefik Hub is the **most modern operating model** of the three —
CRD/GitOps-native, lightest, and years ahead on AI and agent governance. API
Connect's advantage is **incumbency and air-gap pedigree** in exactly the French
institutions I sell into; WSO2's advantage is a **fully open-source, offline-able
core** that sovereignty teams trust. Traefik Hub wins on *where the puck is going*
(AI/agents, GitOps); the incumbents win on *where it has to run today* (offline,
certified, already approved).

## Positioning for the French / regulated market

### Sovereignty & air-gap — the decisive axis

French regulated buyers increasingly require **on-prem or SecNumCloud-qualified
(ANSSI)** deployments, and the strictest (defense, some banking, sensitive public
sector) require **true air-gap**. Two hard dependencies in *this* PoC would not
survive an air-gapped review, and both are addressable:

1. **Hub control-plane SaaS (`api.traefik.io`).** The chart exposes a
   `hub.offline` value ("disables all external network connections"). For a
   sovereign deployment this is the **single most important thing to validate**:
   does offline mode preserve API + AI + MCP gateway features, and how is licensing
   handled without call-home? Get it in writing before proposing.
2. **Hosted NVIDIA NIM endpoint.** This PoC routes to `integrate.api.nvidia.com`
   for convenience. An air-gapped variant **self-hosts the models** — NVIDIA NIM
   containers (`nvcr.io/nim/...`) on on-prem GPUs (the same `nemoguard` guard model
   Traefik's own guide self-hosts), with the AI Gateway pointed at in-cluster
   Services. No architecture change — only the endpoints move inside the perimeter.

!!! note "The air-gapped reference architecture"
    Same three gates, but: Traefik Hub in **offline mode**, **self-hosted NIMs** on
    on-prem/OpenShift GPUs, models and images mirrored into an internal registry,
    and the LLM Guard / Content Guard pointed at in-cluster endpoints. The GitOps
    and TBAC story is **identical** — which is the point.

### Regulatory fit (why a French CISO should care)

- **DORA** (in force 2025): the gateway is a natural **ICT control point** — third-
  party LLM risk, rate/quota for resilience, and an audit trail (every policy is a
  git commit) map directly onto operational-resilience obligations.
- **EU AI Act:** Content Guard + LLM Guard + per-tool authorization + token/guard
  telemetry give a concrete, demonstrable **governance posture** for AI systems.
- **GDPR / data residency:** deterministic **PII blocking before the model**, and
  EU-region or on-prem inference, address data-minimisation and residency.
- **ANSSI / SecNumCloud, HDS (health):** feasible **only** once the offline +
  self-hosted-model architecture above is confirmed; that is the gating item.

### How I would pitch it

> *"For your AI and agent traffic, Traefik Hub gives you a single, GitOps-native
> control point — auth, PII and safety guards, cost governance, and per-tool agent
> authorization — with an audit trail that is your git history. For a sovereign or
> air-gapped estate we run it offline with self-hosted NIMs on your OpenShift GPUs;
> the policy model doesn't change. Where you already run API Connect for classic
> APIs, this is the **AI/agent-native layer** in front of your LLMs and MCP servers,
> not a rip-and-replace."*

## Bottom line

Traefik Hub is the **strongest cloud-native operating model** of the gateways I
work with, and **genuinely ahead on AI and agent (MCP) governance** — a lead that
matters as agentic systems reach regulated production. For the **mainstream French
cloud-native** segment (banks modernising on Kubernetes/OpenShift, GitOps already
in place) I would propose it today. For **air-gapped / SecNumCloud** institutions I
would propose it **conditionally** — contingent on validating offline mode and
standing up self-hosted NIMs — and would keep API Connect in the conversation for
the classic-API, already-certified estate. The most likely winning play is not
either/or but **Traefik Hub as the AI/agent gateway alongside the incumbent**.
