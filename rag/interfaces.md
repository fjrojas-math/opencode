# Proposed Interfaces

## Embedding
```ts
export interface Embedding {
  readonly provider: string
  readonly model: string
  embed(texts: string[]): Promise<number[][]>
}
```

## VectorStore
```ts
export interface VectorStore {
  upsert(items: Array<{ id: string; path: string; start: number; end: number; text: string; embedding: number[] }>): Promise<void>
  query(embedding: number[], topK: number): Promise<Array<{ id: string; path: string; start: number; end: number; score: number }>>
  clear(): Promise<void>
  stats(): Promise<{ vectors: number; files: number }>
}
```

## Tools
- `rag.index(params)`: index/update by globs/ignores.
- `rag.query(params)`: return top‑K relevant snippets.
- `rag.status()`: index metrics.
- `rag.clear()`: wipe index.
