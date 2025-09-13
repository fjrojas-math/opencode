# RAG Configuration

This document describes the RAG (Retrieval-Augmented Generation) configuration schema for OpenCode.

## Overview

RAG enables OpenCode to retrieve relevant context from your codebase or documents to improve AI responses. The configuration includes settings for:

- **Embedding Provider**: How text is converted to vectors
- **Vector Store**: Where embeddings are stored and searched
- **Indexing**: How files are processed and indexed
- **Retrieval**: How relevant context is retrieved

## Configuration Schema

Add a `rag` section to your `opencode.json` or `opencode.jsonc`:

```json
{
  "rag": {
    "enabled": true,
    "embedding": {
      "provider": "openai",
      "model": "text-embedding-3-small",
      "apiKey": "{env:OPENAI_API_KEY}"
    },
    "store": {
      "type": "file",
      "path": "./.opencode/rag_index"
    },
    "indexing": {
      "chunkSize": 512,
      "chunkOverlap": 50,
      "autoIndex": true,
      "include": ["**/*.md", "**/*.py", "**/*.ts"],
      "exclude": ["node_modules/**", "*.test.*"]
    },
    "retrieval": {
      "topK": 5,
      "scoreThreshold": 0.7,
      "contextWindow": 4000
    }
  }
}
```

## Embedding Providers

### OpenAI
```json
{
  "embedding": {
    "provider": "openai",
    "model": "text-embedding-3-small",
    "apiKey": "{env:OPENAI_API_KEY}",
    "dimensions": 1536
  }
}
```

### Cohere
```json
{
  "embedding": {
    "provider": "cohere", 
    "model": "embed-english-v3.0",
    "apiKey": "{env:COHERE_API_KEY}",
    "options": {
      "inputType": "search_document"
    }
  }
}
```

### Hugging Face
```json
{
  "embedding": {
    "provider": "huggingface",
    "model": "sentence-transformers/all-MiniLM-L6-v2",
    "apiKey": "{env:HUGGINGFACE_API_KEY}"
  }
}
```

## Vector Stores

### File-based (Default)
```json
{
  "store": {
    "type": "file",
    "path": "./.opencode/rag_index"
  }
}
```

### In-Memory
```json
{
  "store": {
    "type": "memory"
  }
}
```

### SQLite
```json
{
  "store": {
    "type": "sqlite",
    "path": "./rag.db",
    "collection": "embeddings"
  }
}
```

### Chroma
```json
{
  "store": {
    "type": "chroma",
    "connectionString": "http://localhost:8000",
    "collection": "opencode_documents"
  }
}
```

### Pinecone
```json
{
  "store": {
    "type": "pinecone",
    "connectionString": "{env:PINECONE_ENVIRONMENT_URL}",
    "collection": "my-index",
    "options": {
      "apiKey": "{env:PINECONE_API_KEY}",
      "environment": "us-east1-gcp"
    }
  }
}
```

### Weaviate
```json
{
  "store": {
    "type": "weaviate",
    "connectionString": "http://localhost:8080",
    "collection": "Documents",
    "options": {
      "apiKey": "{env:WEAVIATE_API_KEY}"
    }
  }
}
```

## Indexing Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `chunkSize` | number | 512 | Text chunk size in tokens |
| `chunkOverlap` | number | 50 | Overlap between chunks in tokens |
| `autoIndex` | boolean | false | Automatically index files in the project |
| `include` | string[] | - | File patterns to include for indexing |
| `exclude` | string[] | - | File patterns to exclude from indexing |
| `maxFileSize` | number | 1048576 | Maximum file size to index (bytes) |

### File Patterns

Use glob patterns to control which files are indexed:

```json
{
  "indexing": {
    "include": [
      "**/*.md",
      "**/*.txt", 
      "docs/**/*",
      "src/**/*.py"
    ],
    "exclude": [
      "node_modules/**",
      "*.test.*",
      "dist/**",
      "build/**",
      ".git/**"
    ]
  }
}
```

## Retrieval Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `topK` | number | 5 | Number of top results to retrieve |
| `scoreThreshold` | number | - | Minimum similarity score threshold (0-1) |
| `rerankModel` | string | - | Model for reranking retrieved results |
| `contextWindow` | number | 4000 | Context window size for retrieved content |

## Environment Variables

You can reference environment variables in your configuration using `{env:VARIABLE_NAME}` syntax:

```json
{
  "embedding": {
    "apiKey": "{env:OPENAI_API_KEY}"
  },
  "store": {
    "connectionString": "{env:PINECONE_ENVIRONMENT_URL}"
  }
}
```

## Examples

See the `examples/` directory for complete configuration examples:

- `rag-config.json` - Basic file-based RAG setup
- `rag-chroma-config.json` - Chroma vector database setup
- `rag-pinecone-config.json` - Pinecone cloud setup