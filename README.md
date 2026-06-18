<h1 align="center">Traefik Hub — Triple Gate PoC</h1>

<p align="center">
  <b>API Gateway · AI Gateway · MCP Gateway</b> — defense-in-depth for cloud-native API & AI governance<br/>
  GitOps-first on a local Kubernetes homelab · ArgoCD · declarative everything
</p>

<p align="center">
  <a href="https://yassineteimi.github.io/traefik-hub-triple-gate/"><b>📖 Read the tutorial &amp; benchmark →</b></a>
</p>

---

A hands-on benchmark of **[Traefik Hub](https://doc.traefik.io/traefik-hub/)**'s "Triple Gate" — three enforcement points that govern API, LLM, and agent (MCP) traffic as **defense in depth**: an attack blocked at one gate is still caught by the next. Everything is reconciled declaratively by **ArgoCD**, and the whole thing runs on a single-node Kubernetes homelab with **no GPU required**.

## 🧭 The three gates

| Gate | Enforces | Highlights |
| --- | --- | --- |
| **1 — API Gateway** | Identity & abuse control on a sample REST API | JWT/OAuth-style auth, rate limiting — all declarative, reconciled by ArgoCD |
| **2 — AI Gateway** | Governance on LLM (chat-completion) traffic | Content Guard (regex PII/keyword block), LLM Guard (hosted NVIDIA safety model), semantic cache, token rate-limit/quota, multi-provider failover |
| **3 — MCP Gateway** | Tool-level access control for MCP servers | JWT auth + TBAC — specific identities may call only specific tools; blocked vs allowed tool calls demonstrated |

Routed to **NVIDIA hosted NIMs** (OpenAI-compatible, free `nvapi-` key) for both LLM traffic and the safety guard.

## 🗂️ Repository layout

```text
traefik-hub-triple-gate/
├── docs/        # 📖 the published GitHub Pages tutorial (MkDocs Material)
└── poc/         # ⚙️ the runnable PoC — manifests, Helm values, ArgoCD apps, scripts
    ├── cluster/        # kind/k3d cluster config + bootstrap
    ├── argocd/         # ArgoCD install + app-of-apps
    ├── helm/           # Traefik Hub values (pinned)
    ├── gate1-api/      # sample API + auth + rate-limit
    ├── gate2-ai/       # AI routes + guard middlewares
    ├── gate3-mcp/      # MCP gateway + TBAC
    ├── observability/  # OpenTelemetry + Prometheus + Grafana
    └── scripts/        # idempotent bootstrap, teardown, secret injection
```

GitHub Pages is static and cannot run the cluster, so **`docs/` documents and presents** while **`poc/` runs** on the homelab.

## 🚀 Quick start

> Full, verified prerequisites and step-by-step instructions live in the [tutorial](https://yassineteimi.github.io/traefik-hub-triple-gate/). In short:

```bash
cp .env.example .env          # add your Traefik Hub + NVIDIA tokens (gitignored)
# ... bootstrap scripts land per milestone (see the Prerequisites page)
```

## 🔐 Secrets hygiene

All tokens come from a **gitignored `.env`**, injected as Kubernetes Secrets by scripts — never committed. The published site contains zero secrets.

## 🛠️ Stack

![Traefik Hub](https://img.shields.io/badge/Traefik%20Hub-24A1C1?logo=traefikproxy&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![ArgoCD](https://img.shields.io/badge/Argo%20CD-EF7B4D?logo=argo&logoColor=white)
![NVIDIA NIM](https://img.shields.io/badge/NVIDIA%20NIM-76B900?logo=nvidia&logoColor=white)
![MCP](https://img.shields.io/badge/MCP-AI%20Agents-1F6FEB)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)
![MkDocs Material](https://img.shields.io/badge/MkDocs-Material-526CFE?logo=materialformkdocs&logoColor=white)

## 📫 Connect

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=white)](https://linkedin.com/in/yassine-teimi)
[![Email](https://img.shields.io/badge/Email-EA4335?logo=gmail&logoColor=white)](mailto:yteimi@gmail.com)

---

<p align="center"><sub>A neutral technical benchmark of Traefik Hub for cloud-native API & AI governance. Not affiliated with Traefik Labs.</sub></p>
