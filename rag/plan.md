# Work Plan

## Phase 1 — Skeleton and config
- Define `rag` in config (enabled, embedding, store, index, query).
- Implement interfaces and register tools (no inner logic yet).

## Phase 2 — Local driver
- Implement `sqlite/mem` + in‑memory cosine kNN.
- Line‑based chunking with configurable overlap.

## Phase 3 — Tools
- `rag.index`: walk, chunk, embed, and upsert.
- `rag.query`: embed query and return top‑K snippets.
- `rag.status` and `rag.clear`.

## Phase 4 — Core integration
- Inject snippets in `Session.prompt` when `rag.enabled`.
- Show tool event in CLI.

## Phase 5 — Tests and docs
- Basic coverage for indexing/query and integration.
- Configuration and usage docs.

## Phase 6 — External drivers (optional)
- Pinecone/Qdrant/pgvector as pluggable drivers.

## Acceptance criteria
- Same flows as existing tools, zero friction.
- Clear relevance in answers due to injected context.
- Minimal and safe defaults in configuration.
