# Evaluation Notes

A practitioner's assessment after building the Triple Gate end-to-end, written
through the lens that matters for my market: **French and European regulated
institutions** (banks, insurers, public sector, health), and the stricter subset
that runs **air-gapped or sovereignty-constrained** estates. The benchmark is not
"does it work" (it does) but "would I put this in front of a regulated buyer, and
how does it sit next to the alternatives".

!!! abstract "Scope & method"
    The transferable asset here is a **reproducible benchmark methodology** for
    API/AI/MCP gateways, built hands-on against Traefik Hub, repeatable against any
    gateway. The competitor notes below are a **factual landscape**, not a scoreboard:
    each platform is credited for what it genuinely does well. Vendor claims move
    fast in this space; everything here is **as of late 2025** and linked to a
    source; verify before quoting.

## What impressed me

- **CRD-native, GitOps-first by construction.** Every gate in this PoC is a YAML
  object reconciled by ArgoCD: auth, rate limits, AI guards, and **tool-level
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
  AI/MCP metrics are **OTLP-only**: you must run a collector to land them in
  Prometheus. Content Guard has no first-class counter (blocks only show as `403`),
  and a denied MCP tool call doesn't populate `mcp_tool_name`. The signals are
  excellent; the **out-of-the-box dashboarding is not**, so budget for it.
- **The SaaS control-plane dependency is the headline risk for my market** (see
  below). During the PoC the agent logged `Unable to ping platform api.traefik.io`, a reminder that the gateway data
  plane is self-hosted but the **control plane phones home** by default.
- **Trial/entitlement coupling.** AI and MCP gateways require license entitlements;
  fine for a PoC, but procurement and air-gap teams will want the offline licensing
  story in writing.
- **Deployment model: not Kubernetes-only, but AI/MCP is K8s-first.** Traefik and
  the Hub API Gateway run on [VMs, Docker, Swarm, and plain file config](https://doc.traefik.io/traefik-hub/api-gateway/setup/installation/docker)
  too, which matters for customers who haven't adopted Kubernetes. But the
  **AI Gateway and MCP Gateway features are clearly CRD-first** in the docs. For a
  VM-only estate I'd verify their availability/parity outside Kubernetes rather than
  assume it.

## The landscape: Traefik Hub · IBM API Connect · WSO2 · Gravitee

A fair, point-in-time read of four credible platforms, two of them **French-rooted**
(Traefik, ex-Containous; and Gravitee, founded in Lille), which is itself relevant to
a sovereignty conversation. I know API Connect and WSO2 hands-on; the Traefik column
is this PoC; the Gravitee column is from public docs pending my own PoC.

| Dimension | **Traefik Hub** | **IBM API Connect** | **WSO2 APIM** | **Gravitee** |
| --- | --- | --- | --- | --- |
| Model / origin | Open-core; French-founded | Commercial (DataPower) | Open-core + subscription + Choreo SaaS | Open-core; French-founded (Lille, 2014) |
| Config & GitOps | **CRD-native, GitOps-first** | Mgmt UI/CLI; GitOps add-on | UI + APICTL; config-as-code possible | UI + APIs; K8s Gateway API + GitOps |
| Footprint | **Light** (proxy + agent) | Heavy (Mgmt/Portal/Analytics/DataPower) | Medium-heavy | Medium |
| AI / LLM gateway | First-class: Content + LLM guards, token cost, semantic cache | **GA 2025**: LLM governance, rate/cost, caching, analytics | Emerging | Agent platform: identity/access, guardrails maturing |
| MCP / agent governance | **TBAC** in front of MCP servers (per-identity, per-tool) | MCP via **API→MCP** + ContextForge proxy/guardrails | Emerging | **MCP** (APIs→MCP), **A2A**, agent identity/access |
| Event-native (Kafka/MQTT) | No (HTTP/gRPC) | Limited | Partial | **Yes, core differentiator** |
| Beyond Kubernetes | VMs/Docker/Swarm/file (AI/MCP K8s-first) | VM/appliance/container | VM/container/hybrid | VM/container/hybrid/K8s |
| Air-gap / sovereignty | Offline mode, **validate**; self-host models | **Battle-tested** in regulated banks | OSS core **fully offline-able** | On-prem/hybrid; French-rooted trust |

Sources: IBM [AI Gateway announcement](https://www.ibm.com/new/announcements/how-an-ai-gateway-provides-greater-control-and-visibility-into-ai-services) & [API Connect MCP docs](https://www.ibm.com/docs/en/api-connect/software/12.1.0?topic=tools-ai-gateway-mcp), [ContextForge](https://github.com/IBM/mcp-context-forge); WSO2 [Choreo/subscription model](https://wso2.com/library/blogs/choreo-for-api-management/); Gravitee [AI agent platform](https://www.gravitee.io/platform/ai-agent-management) & [origin](https://siliconcanals.com/gravitee-io-raises-29-7m/); Traefik [multi-provider install](https://doc.traefik.io/traefik-hub/api-gateway/setup/installation/docker).

**Read:** all four are credible; the differences are about *emphasis*, and the field
is moving monthly.

- **Traefik Hub** has the **most GitOps/CRD-native operating model** and the most
  opinionated, composable guard chain (deterministic PII → safety-model → per-tool
  TBAC). Lightest footprint.
- **IBM API Connect** ships a GA AI Gateway (2025) with LLM governance, cost
  controls and caching, plus an MCP story (turn APIs into MCP tools; ContextForge as
  an MCP/A2A proxy with guardrails). Its enduring edge is **incumbency and air-gap
  pedigree** in French banks/insurers.
- **WSO2** is the **open-core, offline-friendly** choice sovereignty teams trust, with
  API + event coverage; AI gateway features are earlier.
- **Gravitee** is, alongside Traefik, **closest to where the market is heading**:
  **event-native** *and* leaning hard into **agent/MCP/A2A governance**, with a
  **French origin** that plays well for sovereignty.

The honest caveat: AI/agent feature sets across all four change fast, so a real
head-to-head needs a **hands-on PoC per vendor**, which is exactly the method this
project demonstrates.

## Positioning for the French / regulated market

### Sovereignty & air-gap: the decisive axis

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
   for convenience. An air-gapped variant **self-hosts the models**: NVIDIA NIM
   containers (`nvcr.io/nim/...`) on on-prem GPUs (the same `nemoguard` guard model
   Traefik's own guide self-hosts), with the AI Gateway pointed at in-cluster
   Services. No architecture change; only the endpoints move inside the perimeter.

!!! note "The air-gapped reference architecture"
    Same three gates, but: Traefik Hub in **offline mode**, **self-hosted NIMs** on
    on-prem/OpenShift GPUs, models and images mirrored into an internal registry,
    and the LLM Guard / Content Guard pointed at in-cluster endpoints. The GitOps
    and TBAC story is **identical**, which is the point.

### Regulatory fit (why a French CISO should care)

- **DORA** (in force 2025): the gateway is a natural **ICT control point**: third-
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
> control point (auth, PII and safety guards, cost governance, and per-tool agent
> authorization) with an audit trail that is your git history. For a sovereign or
> air-gapped estate we run it offline with self-hosted NIMs on your OpenShift GPUs;
> the policy model doesn't change. Where you already run API Connect for classic
> APIs, this is the **AI/agent-native layer** in front of your LLMs and MCP servers,
> not a rip-and-replace."*

## Bottom line

Traefik Hub has one of the **cleanest cloud-native operating models** I've worked
with: GitOps/CRD-native, light, with a composable guard chain and per-tool TBAC that
is genuinely well-executed. It is **not uniquely ahead**, though: IBM API Connect now
ships a GA AI gateway with an MCP story, and **Gravitee** matches the modern direction
(event-native, agent/MCP/A2A) with a French origin of its own. The differentiator is
fit, not a single winner.

For the **mainstream French cloud-native** segment (banks modernising on
Kubernetes/OpenShift with GitOps in place) Traefik Hub is an easy thing to propose
today. For **air-gapped / SecNumCloud** institutions I'd propose it **conditionally**, contingent on validating offline mode and
standing up self-hosted NIMs, and keep the incumbent (API Connect) in the conversation for the classic-API, already-certified
estate. The most likely winning play is rarely rip-and-replace; it's **the right
AI/agent-native gateway alongside what's already approved**, and which gateway that
is deserves a hands-on PoC per vendor, not a datasheet comparison.
