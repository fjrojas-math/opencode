# ICP
---
applyTo: "**"
---

## ICP Compliance Commitment

- The persistent context file `.github/instructions/context.log.md` MUST be read at the start of every session and updated at the end, as required by the ICP. Always use the most recent context block (at the top) for session continuity.

- At the start of every session, explicitly confirm understanding and respect for the Initial Context Protocol (ICP) as defined in `.github/ICP.md`.
- The first action must always be:
  1. Retrieve and present the last recorded context from the persistent context file `.github/instructions/context.log.md` (not from this file), before any other operation.
  2. If no context exists in `.github/instructions/context.log.md`, inform the user and request instructions.
- No further actions may be taken until this protocol is fulfilled.

## User Preferences and Definitions

- Whenever the term "MCP" is used, it refers to **Model Context Protocol** (not Multi-Component/Process or any other meaning).
- All documentation, files, records, and internal notes must always be in English. This rule is secondary in priority to strict ICP compliance.
- All communication with the user must always be in Spanish, regardless of the context file language.
- In chat, always reply in the same language as the user.
- Do not include agent signatures or "Logged by..." lines in documentation.
- When documenting, prefer dedicated documents for substantial topics rather than only using journal entries.
- Always record in persistent memory any lessons, facts, or context learned that are important to remember between sessions, especially those that affect workflow, user preferences, or project continuity. This ensures that knowledge and context are not lost and can be referenced in future sessions.

## GitHub Project Context

- Main project board for RAG development: project number 1 (ID: PVT_kwHOBBudLc4BC-1S) under user fjrojas-math. Use this for syncing issue/project status.

## Lessons Learned

- Always consult the persistent memory file (.github/instructions/memory.instruction.md) for project context, user preferences, and definitions before searching for information externally or in remote services. Only search externally if the information is not found in memory.

## IMPORTANT

- Try to keep things in one function unless composable or reusable
- DO NOT do unnecessary destructuring of variables
- DO NOT use `else` statements unless necessary
- DO NOT use `try`/`catch` if it can be avoided
- AVOID `try`/`catch` where possible
- AVOID `else` statements
- AVOID using `any` type
- AVOID `let` statements
- PREFER single word variable names where possible
- Use as many bun apis as possible like Bun.file()

## Debugging

- To test opencode in the `packages/opencode` directory you can run `bun dev`
