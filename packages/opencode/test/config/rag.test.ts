import { describe, test, expect } from "bun:test"
import { Config } from "../../src/config/config"

describe("RAG Configuration Schema", () => {
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

    const result = Config.Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.enabled).toBe(true)
      expect(result.data.embedding.provider).toBe("openai")
      expect(result.data.embedding.model).toBe("text-embedding-3-small")
      expect(result.data.store.type).toBe("memory")
      // Test defaults
      expect(result.data.indexing?.chunkSize).toBe(512)
      expect(result.data.indexing?.chunkOverlap).toBe(50)
      expect(result.data.indexing?.autoIndex).toBe(false)
      expect(result.data.retrieval?.topK).toBe(5)
      expect(result.data.retrieval?.contextWindow).toBe(4000)
    }
  })

  test("should validate full RAG config with all options", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "cohere",
        model: "embed-english-v3.0",
        apiKey: "test-key",
        baseURL: "https://api.cohere.ai",
        dimensions: 1024,
        options: {
          inputType: "search_document",
        },
      },
      store: {
        type: "chroma" as const,
        connectionString: "http://localhost:8000",
        collection: "my_collection",
        options: {
          distance: "cosine",
        },
      },
      indexing: {
        chunkSize: 256,
        chunkOverlap: 20,
        autoIndex: true,
        include: ["*.md", "*.txt"],
        exclude: ["node_modules/**", "*.test.*"],
        maxFileSize: 2097152,
      },
      retrieval: {
        topK: 10,
        scoreThreshold: 0.7,
        rerankModel: "cohere/rerank-english-v3.0",
        contextWindow: 8000,
      },
    }

    const result = Config.Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.embedding.provider).toBe("cohere")
      expect(result.data.embedding.dimensions).toBe(1024)
      expect(result.data.store.type).toBe("chroma")
      expect(result.data.store.connectionString).toBe("http://localhost:8000")
      expect(result.data.indexing?.chunkSize).toBe(256)
      expect(result.data.indexing?.autoIndex).toBe(true)
      expect(result.data.retrieval?.topK).toBe(10)
      expect(result.data.retrieval?.scoreThreshold).toBe(0.7)
    }
  })

  test("should validate file-based vector store", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "huggingface",
        model: "sentence-transformers/all-MiniLM-L6-v2",
      },
      store: {
        type: "file" as const,
        path: "./rag_index",
      },
    }

    const result = Config.Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.store.type).toBe("file")
      expect(result.data.store.path).toBe("./rag_index")
    }
  })

  test("should validate SQLite vector store", () => {
    const config = {
      enabled: true,
      embedding: {
        provider: "openai",
        model: "text-embedding-ada-002",
      },
      store: {
        type: "sqlite" as const,
        path: "./rag.db",
        collection: "embeddings",
      },
    }

    const result = Config.Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.store.type).toBe("sqlite")
      expect(result.data.store.path).toBe("./rag.db")
      expect(result.data.store.collection).toBe("embeddings")
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
        type: "invalid-store" as any,
      },
    }

    const result = Config.Rag.safeParse(config)
    expect(result.success).toBe(false)
  })

  test("should reject negative chunk sizes", () => {
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
        chunkSize: -100,
      },
    }

    const result = Config.Rag.safeParse(config)
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
        scoreThreshold: 1.5, // Invalid: should be <= 1
      },
    }

    const result = Config.Rag.safeParse(config)
    expect(result.success).toBe(false)
  })

  test("should integrate with main config schema", () => {
    const config = {
      $schema: "https://opencode.ai/config.json",
      model: "anthropic/claude-3-sonnet",
      rag: {
        enabled: true,
        embedding: {
          provider: "openai",
          model: "text-embedding-3-small",
          apiKey: "sk-test",
        },
        store: {
          type: "memory" as const,
        },
        indexing: {
          autoIndex: true,
          include: ["*.md"],
        },
      },
    }

    const result = Config.Info.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.rag?.enabled).toBe(true)
      expect(result.data.rag?.embedding.provider).toBe("openai")
      expect(result.data.rag?.store.type).toBe("memory")
      expect(result.data.rag?.indexing?.autoIndex).toBe(true)
    }
  })

  test("should handle disabled RAG config", () => {
    const config = {
      enabled: false,
      embedding: {
        provider: "openai",
        model: "text-embedding-3-small",
      },
      store: {
        type: "memory" as const,
      },
    }

    const result = Config.Rag.safeParse(config)
    expect(result.success).toBe(true)

    if (result.success) {
      expect(result.data.enabled).toBe(false)
    }
  })
})