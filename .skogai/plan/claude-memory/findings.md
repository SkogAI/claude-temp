# Findings & Decisions

## Architecture

- **Language**: TypeScript/Node.js (ES2022, ESNext modules)
- **Storage**: SQLite with sqlite-vec extension for vector search
- **Embeddings**: @xenova/transformers, all-MiniLM-L6-v2 (384-dim, offline)
- **Distribution**: npm package + Claude Code plugin via skogai-marketplace
- **MCP server**: Bundled via esbuild (~694KB), exposes search + show tools

## Data Flow

```
~/.claude/projects/**/*.jsonl
  → sync (atomic copy to archive)
  → parse (extract user/assistant exchanges)
  → summarize (optional, external script)
  → embed (384-dim vectors)
  → store (SQLite + vec_exchanges virtual table)
  → search (vector similarity / text / combined / multi-concept AND)
```

## Database Schema

- `exchanges` — core table (id, project, timestamp, messages, embedding, session context)
- `tool_calls` — FK to exchanges (tool_name, input, result)
- `vec_exchanges` — virtual table for vector similarity (FLOAT[384])

## Key Paths

| Path | Purpose |
|------|---------|
| `~/.config/skogai/conversation-archive/` | Synced JSONL copies |
| `~/.config/skogai/conversation-index/` | Index + DB |
| `~/.config/skogai/conversation-index/db.sqlite` | Main database |

## Technical Decisions

| Decision | Rationale |
| -------- | --------- |
| Single SQLite file | Portable, no server, easy backup |
| Atomic rename for sync | Prevents partial file corruption |
| External summarization script | Decoupled — works with ollama, claude, queue |
| 30s vitest timeout | Embedding + indexing is CPU-heavy |
| esbuild bundle for MCP | Single file distribution, fast startup |

## Issues Encountered

| Issue | Resolution |
| ----- | ---------- |
| better-sqlite3 native rebuild needed per Node version | postinstall script |
| MCP server pointed to bash script instead of node | wrapper.js indirection |
| queue CLI fails inside Claude Code (CLAUDECODE env) | bypass with `CLAUDECODE= <command>` |

## Codebase Stats

- 20 TypeScript source files, ~3,500 lines
- 11 test files (vitest)
- 6 production dependencies
- No CI/CD (manual releases, changelog-driven)
