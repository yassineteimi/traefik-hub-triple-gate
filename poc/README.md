# PoC — runnable code

The runnable half of the project. GitHub Pages (`../docs/`) documents and presents; **this** is what executes on the homelab cluster. Everything is declarative and reconciled by ArgoCD wherever possible.

| Directory | Contents | Milestone |
| --- | --- | --- |
| `cluster/` | kind/k3d cluster config + bootstrap | M0 |
| `argocd/` | ArgoCD install + app-of-apps | M0 |
| `helm/` | Traefik Hub Helm values (pinned versions) | M0 |
| `gate1-api/` | Sample API + auth + rate-limit manifests | M1 |
| `gate2-ai/` | AI Gateway routes + guard middlewares | M2 |
| `gate3-mcp/` | MCP Gateway + TBAC | M3 |
| `observability/` | OpenTelemetry + Prometheus + Grafana | M5 |
| `scripts/` | Idempotent bootstrap, teardown, secret injection | all |

!!! Secrets
    No secrets live here. Scripts in `scripts/` read the gitignored `../.env` and inject values as Kubernetes Secrets at runtime.
