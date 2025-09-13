# RAG Patterns and Best Practices for Code Assistants

## 1. Standard RAG Pattern in Code Assistants

**Retrieval-Augmented Generation (RAG)** combines information retrieval with large language models (LLMs) to provide more accurate and context-aware answers. In the context of code assistants, the standard RAG pattern involves:

- **Indexing:** Chunking code, documentation, and other resources, converting them to embeddings, and storing them in a vector store (local or external).
- **Retrieval:** Embedding the user's query and performing a semantic search in the vector store to retrieve the top-K most relevant fragments.
- **Generation:** The LLM receives the user's prompt along with the retrieved fragments, enabling it to generate more precise and context-rich responses.
- **Automation:** The user does not need to invoke special commands; relevant context is injected automatically into every query.
- **Multiple sources:** It is both viable and recommended to combine context from the repository and external sources (official docs, forums, articles, etc.).

## 2. Comparison with opencode's Current Flow

- **Current approach:** Uses textual and heuristic search (grep, ls, read) to select relevant fragments by literal match.
- **True RAG:** Uses semantic search (embeddings), enabling the retrieval of relevant fragments even if there is no literal match.
- **Both:** Inject relevant context into the prompt, but RAG does so more precisely and at scale.

## 3. Advantages of Automatic RAG

- More precise and contextualized answers.
- Scales to large projects and poorly documented codebases.
- Enables enriching context with external information.

## 4. Combining Internal and External Context

A robust RAG pipeline can index and retrieve from both the codebase and external sources (such as official documentation, technical articles, or Q&A forums). This allows the assistant to:

- Answer project-specific questions using internal code and docs.
- Provide best practices, ecosystem knowledge, and up-to-date information from external sources.
- Transparently indicate the origin of each retrieved fragment if desired.

## 5. Suggested Next Steps

- Document configuration examples and automatic RAG flows.
- Prototype the combination of internal and external context in the RAG pipeline.
- Use this document as a living reference for RAG patterns and implementation guidance in opencode.

---
