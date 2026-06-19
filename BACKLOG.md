# Backlog — v2 ideas

Deferred enhancements to tackle after the v1 tutorial (the three gates + unified demo + observability) is complete.

## Gate 1 — API Gateway

- **API versioning + Developer Portal.** Demonstrate Traefik Hub's API management layer:
  versioned APIs (e.g. `v1`/`v2` of the sample API), an **API Portal** for developer
  self-service (browse APIs, generate tokens/keys), and how a publisher promotes a new
  version — all **GitOps-managed** (declared in `poc/`, reconciled by ArgoCD), consistent
  with the rest of the PoC. Requires `hub.apimanagement.enabled=true`.
  _Suggested by the author during M1; keep for v2._
