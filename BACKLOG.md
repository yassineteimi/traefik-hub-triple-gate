# Backlog — v2 ideas

Deferred enhancements to tackle after the v1 tutorial (the three gates + unified demo + observability) is complete.

## Gate 2 — AI Gateway

- **Semantic cache.** Serve repeated/similar prompts from cache without an LLM round-trip
  (latency + cost win). Traefik Hub AI Gateway semantic-cache middleware.
- **Token rate-limit / quota.** Per-identity token budgets for cost governance.
- **Automatic provider failover.** Route to a second LLM (OpenAI or local Ollama) when the
  primary NVIDIA NIM fails. `.env` already has placeholders `OPENAI_API_KEY` / `OLLAMA_API_BASE`.

  _Deferred from M2 (v1 ships routing + Content Guard + LLM Guard); finish in v2._

## Gate 1 — API Gateway

- **API versioning + Developer Portal.** Demonstrate Traefik Hub's API management layer:
  versioned APIs (e.g. `v1`/`v2` of the sample API), an **API Portal** for developer
  self-service (browse APIs, generate tokens/keys), and how a publisher promotes a new
  version — all **GitOps-managed** (declared in `poc/`, reconciled by ArgoCD), consistent
  with the rest of the PoC. Requires `hub.apimanagement.enabled=true`.
  _Suggested by the author during M1; keep for v2._
