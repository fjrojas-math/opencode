# Vision and Scope

## Goal
Add pluggable RAG capabilities to opencode to improve context retrieval using real embeddings and vector stores, while maintaining the same UX as existing tools (ls/grep/read), with zero additional friction.

## Principles
- Real embeddings: use existing or local provider models.
- Pluggable vector stores: local driver by default, optional external (Pinecone/Qdrant/pgvector).
- Native integration: expose as tools and inject context automatically on each prompt.
- Simple configuration: only `rag` params in config; no extra daily workflow steps.
- Safety and limits: operate within the `worktree`, respect sizes and truncation.

## Scope (V1)
- RAG tooling: `rag.index`, `rag.query`, `rag.status`, `rag.clear`.
- Local driver (sqlite/mem) + in-memory cosine kNN.
- Automatic injection of relevant snippets before each generation.
- Minimal configuration to enable and select embedding/model and store.

## Out of Scope (V1)
- Dedicated TUI UI is not prioritized.
- Multi-repo or cross-project is not prioritized.
- Continuous background indexing is not prioritized.
