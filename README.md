# 🌐 Neuralis Black | GEO Audit SaaS Platform
**Generative Engine Optimization Audit & Strategic Intelligence Layer**

Automated measurement, simulation, and optimization of digital content performance across AI search engines, LLM retrieval pipelines, and generative answer surfaces. Qwen serves as the primary strategic intelligence layer, with DeepSeek deployed for heavy NLP, entity resolution, and fallback parsing.

## 🏗️ Architecture
```
Client (Next.js) → API Gateway → FastAPI (Router/Tenant) → AI Orchestrator (Qwen/DeepSeek)
                                      ↓
                              PostgreSQL + pgvector + TimescaleDB
                                      ↓
                              Celery Workers (Crawl/Embed/Simulate)
```

## 🧠 AI Routing Strategy
| Task | Primary | Fallback Trigger |
|------|---------|------------------|
| Strategic GEO synthesis, executive briefs | **Qwen** | - |
| Entity extraction, multilingual parsing | Qwen → **DeepSeek** | Tokens > 8000, entities > 75, non-EN |
| Schema validation & repair | Qwen → **DeepSeek** | Validation fails > 2x |
| Citation trend & forecasting | Qwen + Time-series ML | DeepSeek for semantic drift mapping |

## 📊 Default GEO Scoring Rubric
| Dimension | Weight | Focus |
|-----------|--------|-------|
| AI Citation Readiness | 30% | Direct answer density, FAQ alignment, hallucination resistance |
| Entity & Semantic Clarity | 25% | KG match rate, disambiguation, cross-reference consistency |
| Structural AI-Optimization | 20% | Schema.org coverage, heading hierarchy, formatting density |
| Authority & Trust Signals | 15% | E-E-A-T indicators, publisher transparency, citation history |
| Cross-Engine Visibility | 10% | Citation frequency, position stability, competitive SOV |

## 🚀 Quick Start
1. Clone & init: `git clone <repo> && cd neuralis-geo-audit`
2. Copy env: `cp .env.example .env`
3. Spin local stack: `docker compose up -d`
4. Run DB init: `psql -h localhost -U postgres -f sql/init.sql`
5. Start workers: `celery -A packages.ai_router.worker worker --loglevel=info`
6. Run API: `uvicorn api.main:app --reload`

## 📦 SaaS Features
- Multi-tenant row-level security (PostgreSQL RLS)
- Usage-based metering (Stripe-ready)
- Vector-isolated embeddings per tenant
- SOC 2 / GDPR compliant audit logging
- Webhook & API-first architecture

## 🗺️ Roadmap
- [x] Core schema + pgvector pipeline
- [x] AI routing + fallback thresholds
- [x] Terraform AWS baseline
- [ ] Multi-engine simulation router
- [ ] Stripe billing + quota enforcement
- [ ] White-label dashboard + SSO

## 🔐 Security Baseline
- AES-256 at rest, TLS 1.3 in transit
- Tenant isolation via `app.current_tenant_id` session var + RLS
- Immutable audit logs (TimescaleDB + S3 versioning)
- Rate-limited AI endpoints + API key rotation

---
> **Maintainer:** Neuralis Black Core Team
> **License:** Proprietary (Internal Use) | Contact: initiate@neuralisblack.com
