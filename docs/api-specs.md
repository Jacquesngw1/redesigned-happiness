# 🌐 Neuralis GEO Audit API v1

## `/api/v1/audit` (POST)

**Purpose:** Queue content for GEO scoring & AI simulation

```http
POST /api/v1/audit
Authorization: Bearer <tenant_jwt>
X-Tenant-ID: <uuid>
Content-Type: application/json

Body:
{
  "urls": ["https://example.com/feature-1", "https://example.com/pricing"],
  "engines": ["perplexity", "google_ai_overview", "bing_copilot"],
  "scoring_profile": "default"
}

Response (202):
{
  "audit_id": "uuid",
  "status": "queued",
  "estimated_completion": "2026-04-09T14:30:00Z",
  "webhook_url": "https://your-domain.com/webhooks/geo"
}
```

## `/api/v1/simulate` (POST)

**Purpose:** Run AI engine simulation against scored content

```http
POST /api/v1/simulate
Authorization: Bearer <tenant_jwt>
Body:
{
  "page_id": "uuid",
  "query_set": ["best enterprise SaaS analytics"],
  "engine_targets": ["perplexity", "chatgpt_search"],
  "citation_tracking_days": 30
}

Response (200):
{
  "simulation_id": "uuid",
  "results": [
    {
      "engine": "perplexity",
      "position": 3,
      "cited": true,
      "citation_snippet": "...",
      "confidence": 0.89
    }
  ]
}
```

## `/api/v1/track/citations` (GET)

**Purpose:** Fetch time-series citation visibility

```http
GET /api/v1/track/citations?page_id=uuid&range=30d
Authorization: Bearer <tenant_jwt>

Response (200):
{
  "page_id": "uuid",
  "total_citations": 142,
  "trend": [
    {"date": "2026-04-01", "count": 12, "engines": {"perplexity": 8, "copilot": 4}}
  ],
  "top_queried_phrases": ["geographic risk audit"]
}
```
