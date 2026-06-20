# Traefik Hub: Triple Gate PoC

A hands-on benchmark of **[Traefik Hub](https://doc.traefik.io/traefik-hub/)**'s *Triple Gate*: three enforcement points that govern **API**, **AI (LLM)**, and **agent (MCP)** traffic as **defense in depth**. Everything is reconciled declaratively by **ArgoCD** on a single-node Kubernetes homelab, **no GPU required**.

!!! abstract "What this is"
    A neutral technical evaluation of Traefik Hub for **cloud-native API and AI governance**, built and documented step by step so you can reproduce it. It doubles as a portfolio piece; quality and clarity are first-class goals alongside "it works".

## The three gates

| Gate | What it enforces |
| --- | --- |
| **Gate 1: API Gateway** | Identity (JWT/OAuth-style auth) and abuse control (rate limiting) on a sample REST API. |
| **Gate 2: AI Gateway** | Governance on LLM traffic: Content Guard (regex PII/keyword), LLM Guard (hosted NVIDIA safety model), semantic cache, token rate-limit/quota, and multi-provider failover. |
| **Gate 3: MCP Gateway** | Tool-level access control (TBAC) for Model Context Protocol servers: only specific identities may call specific tools. |

## Why "defense in depth"

The gates compose. A prompt-injection attempt that tries to make an agent exfiltrate data can be **stopped or constrained at multiple layers**: refused auth at the edge, scrubbed by a content guard, denied a tool by TBAC. The [Unified Demo](unified-demo.md) walks one scripted end-to-end scenario through all three.

## How to use this site

1. **[Prerequisites](prerequisites.md)**: stand up the homelab and verify every tool and SaaS dependency live.
2. **[Architecture](architecture.md)**: the gates, what each enforces, and the end-to-end request flow.
3. **The Three Gates**: one tutorial chapter each: [API](gates/api-gateway.md), [AI](gates/ai-gateway.md), [MCP](gates/mcp-gateway.md).
4. **[Unified Demo](unified-demo.md)**: the multi-gate attack scenario.
5. **[Observability](observability.md)**: OpenTelemetry + Prometheus + Grafana findings.
6. **[Evaluation Notes](evaluation.md)**: what impressed, what I'd flag, and how Traefik's GitOps model compares to other API management platforms.

---

> Built and documented by [Yassine TEIMI](https://github.com/yassineteimi). All tokens come from a gitignored `.env`; this public site contains zero secrets.
