# Gate 2 — AI Gateway

!!! note "Status: planned (Milestone M2)"
    Enable `hub.aigateway.enabled=true`, route chat-completion to the NVIDIA hosted NIM, and attach governance middlewares per the official docs.

## Coming here

- Enable the AI Gateway (`hub.aigateway.enabled=true`).
- Route chat-completion traffic to the NVIDIA hosted NIM endpoint.
- **Content Guard** — regex-based deterministic PII / keyword blocking.
- **LLM Guard** — pointed at a hosted NVIDIA safety model.
- **Semantic cache** — cut duplicate LLM calls.
- **Token rate-limit / quota** — cost governance.
- **Automatic failover** to the second provider.
