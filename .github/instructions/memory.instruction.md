---
applyTo: "**"
---

# User Preferences and Definitions

- Whenever the term "MCP" is used, it refers to **Model Context Protocol** (not Multi-Component/Process or any other meaning).
- All documentation, files, records, and internal notes must always be in English.
- In chat, always reply in the same language as the user.
- Do not include agent signatures or "Logged by..." lines in documentation.
- When documenting, prefer dedicated documents for substantial topics rather than only using journal entries.
- Always record in persistent memory any lessons, facts, or context learned that are important to remember between sessions, especially those that affect workflow, user preferences, or project continuity. This ensures that knowledge and context are not lost and can be referenced in future sessions.

# GitHub Project Context

- Main project board for RAG development: project number 1 (ID: PVT_kwHOBBudLc4BC-1S) under user fjrojas-math. Use this for syncing issue/project status.

# Lessons Learned

- Always consult the persistent memory file (.github/instructions/memory.instruction.md) for project context, user preferences, and definitions before searching for information externally or in remote services. Only search externally if the information is not found in memory.

# Last session

- Date: 2025-09-13
- Context: No pending tasks registered.
- Status: Ready to receive new instructions or continue from the last point if specified.

# Next session startup task (MANDATORY)

- Task: At the start of every session, always consult the current state of the main GitHub project board (RAG Development, project 1) under user fjrojas-math using the GitHub CLI (gh). Summarize all active issues/tasks, their status, and priorities for the user. Then, ask the user cómo desea proceder o en qué tarea quiere ayuda.
- Policy: There must always be a concrete startup task in this file. If no user task is pending, set a default like this one.
- If at the start of a session there are no clear instructions from the user, always review the current state of the project (e.g., main GitHub project board, key files, pending tasks) and ask the user how to proceed, based on what you observe in the project.
