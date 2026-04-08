CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Tenants
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  plan TEXT NOT NULL CHECK (plan IN ('starter','growth','enterprise')),
  api_quota INT DEFAULT 10000,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- Content Pages
CREATE TABLE content_pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  url TEXT NOT NULL UNIQUE,
  title TEXT,
  canonical_url TEXT,
  raw_html TEXT,
  parsed_json JSONB,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','crawling','parsed','scored','failed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE content_pages ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_iso_pages ON content_pages USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Embeddings
CREATE TABLE content_embeddings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id UUID REFERENCES content_pages(id) ON DELETE CASCADE,
  chunk_index INT,
  embedding VECTOR(768),
  text_chunk TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_geo_embeddings_hnsw ON content_embeddings USING hnsw (embedding vector_cosine_ops);
ALTER TABLE content_embeddings ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_iso_embed ON content_embeddings
  USING (page_id IN (SELECT id FROM content_pages WHERE tenant_id = current_setting('app.current_tenant_id')::uuid));

-- GEO Scores
CREATE TABLE geo_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id UUID REFERENCES content_pages(id),
  composite_score DECIMAL(5,2) CHECK (composite_score BETWEEN 0 AND 100),
  dimension_scores JSONB,
  recommendations JSONB,
  engine_context JSONB,
  scored_at TIMESTAMPTZ DEFAULT NOW(),
  version INT DEFAULT 1
);
ALTER TABLE geo_scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_iso_scores ON geo_scores
  USING (page_id IN (SELECT id FROM content_pages WHERE tenant_id = current_setting('app.current_tenant_id')::uuid));

-- Audit Log (TimescaleDB)
CREATE TABLE audit_logs (
  id UUID DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  action TEXT NOT NULL,
  payload JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
SELECT create_hypertable('audit_logs', 'created_at');
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_iso_logs ON audit_logs USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
