import os

import psycopg2.extras
from celery import Celery
from sentence_transformers import SentenceTransformer

app = Celery(
    "neuralis_geo",
    broker=os.getenv("REDIS_URL", "redis://:password@localhost:6379/0"),
)
model = SentenceTransformer("BAAI/bge-m3")  # 1024d output, sliced to 768 if needed


@app.task(bind=True, max_retries=3)
def embed_chunks(self, page_id: str, chunks: list[dict]):
    vectors = (
        model.encode([c["text"] for c in chunks], normalize_embeddings=True)[
            :, :768
        ].tolist()
    )
    rows = [
        (page_id, i, vec, c["text"], c["meta"])
        for i, (vec, c) in enumerate(zip(vectors, chunks))
    ]
    database_url = os.getenv("DATABASE_URL", "")
    if not database_url:
        raise ValueError("DATABASE_URL environment variable is not set")
    dsn = database_url.replace("postgresql+asyncpg://", "postgresql://")
    with psycopg2.connect(dsn) as conn:
        with conn.cursor() as cur:
            psycopg2.extras.execute_batch(
                cur,
                """
                INSERT INTO content_embeddings (page_id, chunk_index, embedding, text_chunk, metadata)
                VALUES (%s, %s, %s, %s, %s)
            """,
                rows,
            )
    return f"Embedded {len(rows)} chunks for {page_id}"
