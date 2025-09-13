<!--
This document is a local extension for this fork and is NOT part of the upstream project. It defines an internal protocol for agent-human context management and can be removed or relocated if submitting a pull request to the original repository.
-->

# Initial Context Protocol (ICP)

## Purpose

The Initial Context Protocol (ICP) enables agents and humans to seamlessly resume collaboration by transmitting and recovering context between sessions. Its goal is to ensure continuity, shared understanding, and natural interaction, similar to how humans remember the last point of a conversation.

## Minimum Operational Requirements

1. **Persistent Memory Access**
   - The agent must consult and update persistent memory at the start and end of every session.

2. **Context Recording**
   - At session end, the agent records a brief summary of the last relevant state, pending instructions, and key context.

3. **Context Retrieval**
   - At session start, the agent retrieves and presents the last recorded context to the user before any other action.

4. **Fallback Behavior**
   - If no prior context exists, the agent must inform the user and ask how to proceed.

5. **Language Policy**
   - All records and documentation must be in English. Chat interactions should match the user's language.

## Definitions

- **Session**: A period of continuous interaction between the agent and a human user.
- **Context**: The essential information (state, instructions, goals) needed to resume work without loss of continuity.
- **Persistent Memory**: A file or storage mechanism (e.g., `.github/instructions/memory.instruction.md`) where context is saved between sessions.

## Example Workflow

1. User ends a session. The agent writes a summary and pending tasks to persistent memory.
2. User returns. The agent reads the last context, summarizes it, and asks how to proceed.

## Agent Compliance Workflow

To ensure all agents comply with the ICP, the following workflow must be implemented:

1. **Session Start Hook**
   - On session start, the agent must:
     - Read persistent memory (e.g., `.github/instructions/memory.instruction.md`).
     - Retrieve the last recorded context (summary, pending tasks, key state).
     - Present this context to the user before executing any other action.
     - If no context exists, inform the user and request instructions.

2. **Session End Hook**
   - On session end, the agent must:
     - Write a brief summary of the current state, pending instructions, and key context to persistent memory.

3. **Enforcement Policy**
   - The agent must not perform user actions until the context has been presented or its absence reported.
   - The agent should log whether ICP compliance was achieved for each session.

4. **Reusable Functionality**
   - Implement a standard function (e.g., `checkAndPresentContext()`) to be called at the start of every session by all agents.
   - Document and require this function in agent development guidelines.

## Notes

- The ICP is designed to be simple and robust, supporting both manual and automated workflows.
- This document defines the minimum requirements for ICP to be considered operational between agent and human.
