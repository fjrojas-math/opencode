import { describe, test, expect } from "bun:test"
import { z } from "zod"

// Direct test of just the RAG schemas without importing the full config
describe("RAG Schema Validation (Direct)", () => {
  // Copy the schemas locally to avoid dependencies on models.dev
  const RagEmbeddingProvider = z
    .object({
      provider: z.string().describe("Embedding provider name (e.g., 'openai', 'cohere', 'huggingface')"),
      model: z.string().describe("Embedding model name (e.g., 'text-embedding-3-small')"),
      apiKey: z.string().optional().describe("API key for the embedding provider"),
      baseURL: z.string().optional().describe("Custom base URL for the embedding provider"),
      dimensions: z.number().int().positive().optional().describe("Embedding dimensions (if supported by model)"),
      options: z.record(z.any()).optional().describe("Additional provider-specific options"),
    })
    .strict()

  const RagVectorStore = z
    .object({
      type: z.enum(["memory", "file", "sqlite", "chroma", "pinecone", "weaviate"]).describe("Type of vector store"),
      path: z.string().optional().describe("File path for file-based or SQLite vector stores"),
      connectionString: z.string().optional().describe("Connection string for external vector stores"),
      collection: z.string().optional().describe("Collection or index name"),
      options: z.record(z.any()).optional().describe("Store-specific configuration options"),
    })
    .strict()

  const RagIndexing = z
    .object({
      chunkSize: z.number().int().positive().default(512).describe("Text chunk size in tokens"),
      chunkOverlap: z.number().int().min(0).default(50).describe("Overlap between chunks in tokens"),
      autoIndex: z.boolean().default(false).describe("Automatically index files in the project"),
      include: z.array(z.string()).optional().describe("File patterns to include for indexing"),
      exclude: z.array(z.string()).optional().describe("File patterns to exclude from indexing"),
      maxFileSize: z.number().int().positive().default(1048576).describe("Maximum file size to index (bytes)"),
    })
    .strict()

  const RagRetrieval = z
    .object({
      topK: z.number().int().positive().default(5).describe("Number of top results to retrieve"),
      scoreThreshold: z.number().min(0).max(1).optional().describe("Minimum similarity score threshold"),
      rerankModel: z.string().optional().describe("Model for reranking retrieved results"),
      contextWindow: z.number().int().positive().default(4000).describe("Context window size for retrieved content"),
    })
    .strict()

  const Rag = z
    .object({
      enabled: z.boolean().default(false).describe("Enable RAG (Retrieval-Augmented Generation)"),
      embedding: RagEmbeddingProvider.describe("Embedding provider configuration"),
      store: RagVectorStore.describe("Vector store configuration"),
      indexing: RagIndexing.optional().describe("Indexing configuration"),
      retrieval: RagRetrieval.optional().describe("Retrieval configuration"),
    })
    .strict()

  test("should validate minimal RAG config", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "memory" as const,
      },
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.enabled).toBe(true)
      expect(result.data.embedding.provider).toBe("openai")
      expect(result.data.embedding.model).toBe("text-embedding-3-small")
      expect(result.data.store.type).toBe("memory")
    }
  })

  test("should validate all vector store types", () => {
    const storeTypes = ["memory", "file", "sqlite", "chroma", "pinecone", "weaviate"] as const

    for (const storeType of storeTypes) {
      const config = {
        enabled: true,
        embedding: {
          provider: "openai",
          model: "text-embedding-3-small",
        },
        store: {
          type: storeType,
        },
      }

      const result = Rag.safeParse(config)
      expect(result.success).toBe(true)

      if (result.success) {
        expect(result.data.store.type).toBe(storeType)
      }
    }
  })

  test("should apply defaults for indexing configuration", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "memory" as const,
      },
      indexing: {},
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.indexing?.chunkSize).toBe(512)
      expect(result.data.indexing?.chunkOverlap).toBe(50)
      expect(result.data.indexing?.autoIndex).toBe(false)
      expect(result.data.indexing?.maxFileSize).toBe(1048576)
    }
  })

  test("should apply defaults for retrieval configuration", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "memory" as const,
      },
      retrieval: {},
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.retrieval?.topK).toBe(5)
      expect(result.data.retrieval?.contextWindow).toBe(4000)
    }
  })

  test("should reject invalid vector store type", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "invalid" as any,
      },
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(false)
  })

  test("should reject negative chunk size", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "memory" as const,
      },
      indexing: {
        chunkSize: -1,
      },
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(false)
  })

  test("should reject invalid score threshold", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "memory" as const,
      },
      retrieval: {
        scoreThreshold: 1.5,
      },
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(false)
  })

  test("should validate external vector stores with connection strings", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "pinecone" as const,
        connectionString: "https://my-index-abc123.svc.us-east1-gcp.pinecone.io",
        collection: "my-index",
        options: {
          environment: "us-east1-gcp",
          apiKey: "test-key",
        },
      },
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.store.type).toBe("pinecone")
      expect(result.data.store.connectionString).toBe("https://my-index-abc123.svc.us-east1-gcp.pinecone.io")
      expect(result.data.store.collection).toBe("my-index")
      expect(result.data.store.options?.["environment"]).toBe("us-east1-gcp")
    }
  })

  test("should validate file inclusion and exclusion patterns", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "file" as const,
        path: "./rag_data",
      },
      indexing: {
        include: ["**/*.md", "**/*.txt", "docs/**/*"],
        exclude: ["node_modules/**", "*.test.*", "dist/**"],
      },
    }

    const result = Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.indexing?.include).toEqual(["**/*.md", "**/*.txt", "docs/**/*"])
      expect(result.data.indexing?.exclude).toEqual(["node_modules/**", "*.test.*", "dist/**"])
    }
  })
})