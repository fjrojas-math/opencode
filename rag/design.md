# High-level Design

## Components
- Embedding: `embed(text) -> number[]` (configurable provider).
- VectorStore: `upsert(chunks)`, `query(embedding, topK)`, `clear()`, `stats()`.
- Chunking: line-based with overlap; file/size limits.
- RAG Tools: indexing, querying, status, cleanup.
- Core integration: automatic snippet injection in `Session.prompt` as synthetic parts.

## Flow (automatic retrieval)
1. User submits a prompt.
2. If `rag.enabled`, build a query (user text +/- recent messages).
3. `Embedding.embed(query)`.
4. `VectorStore.query(embedding, topK)`.
5. Convert results into `file://` snippets with ranges, same as `read`.
6. Add synthetic parts before calling the model.

## Persistence
- Local driver (V1): files/DB under `Global.Path.state` per `projectID`.
- Keys derived from `worktree` + `projectID` for isolation.

## Extensibility
- External drivers via config/plugins (`store.driver`).
- Optional `chat.context` hook for plugins to contribute extra context.
