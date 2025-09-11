# ADR 0001 — RAG architecture and integration level

Date: 2025-09-11

## Context
We need to add RAG with real embeddings and pluggable vector stores, without changing the CLI UX: it must integrate as tools and automatically contribute context to every prompt.

## Decision
- Expose RAG as tools (`rag.index`, `rag.query`, `rag.status`, `rag.clear`).
- Inject relevant snippets in `Session.prompt` when `rag.enabled`.
- Implement local driver first (sqlite/mem) and cosine kNN; add external drivers later.
- Reuse `Provider`/`Auth` layers for embeddings when applicable.

## Consequences
- Minimal friction for the user: same interaction patterns as `ls/grep`.
- Extensible architecture: additional drivers via config/plugin.
- Controlled initial scope; tangible relevance improvements from V1.
