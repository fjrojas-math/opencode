# RAG — Working Area

This folder contains brainstorming, design, and planning artifacts for the pluggable RAG capability for opencode. We keep it in-repo so work persists across sessions and collaboration is easy.

## Structure
- `vision.md`: goals, scope, and principles.
- `design.md`: architecture and integration flow.
- `interfaces.md`: proposed contracts (Embedding/VectorStore/Tools).
- `plan.md`: phases and acceptance criteria.
- `tasks.md`: backlog and operational checklist.
- `decisions/`: ADRs for key decisions.
- `journal/`: chronological working notes.
\- Templates:
  - `decisions/ADR-TEMPLATE.md`
  - `design-note-template.md`

## Conventions
- Documents in English, concise and actionable.
- One ADR per relevant decision (`YYYYMMDD-name.md`).
- In `journal/`, use one `YYYY-MM-DD.md` per day with short bullets.
- Keep this folder in sync with the actual code state.
\- Prefer creating new ADRs/design notes using the provided templates.

## Goal
Integrate RAG with real embeddings and pluggable vector stores, at the same integration level as existing tools (ls/grep), automatically enriching context without adding friction for the end user.
