# Task Plan: claude-memory — episodic memory for Claude Code

## Goal

Production-quality semantic search over Claude Code conversations with reliable indexing, summarization, and MCP integration.

## Current Phase

Phase 2 (stabilization)

## Phases

### Phase 1: Core Pipeline (complete)

- [x] JSONL parsing + exchange extraction
- [x] Vector embeddings (Xenova/all-MiniLM-L6-v2, 384-dim)
- [x] SQLite + sqlite-vec storage
- [x] CLI (sync, search, show, stats, index)
- [x] MCP server (search + show tools)
- [x] Claude Code plugin with SessionStart hook
- [x] Multi-concept AND search
- [x] File metadata (size/line count) to avoid 256KB Read limit
- [x] Exclusion marker system
- **Status:** complete

### Phase 2: Stabilization & Quality

- [ ] Fix tool_use_id correlation (parser.ts:146 TODO)
- [ ] Add CI/CD (GitHub Actions — tests, lint, publish)
- [ ] Test suite health check (verify all 11 test files pass)
- [ ] Queue-based summarization reliability
- [ ] Version bump strategy (currently v1.0.13, all 0.1.0 semver)
- **Status:** in_progress

### Phase 3: Search Quality

- [ ] Evaluate embedding model alternatives
- [ ] Search result ranking improvements
- [ ] Summary quality evaluation across models
- [ ] Performance benchmarks (index speed, search latency)
- **Status:** pending

### Phase 4: Integration Hardening

- [ ] Plugin install experience (marketplace reliability)
- [ ] Cross-platform Node.js compatibility (better-sqlite3 rebuilds)
- [ ] Documentation refresh (README accuracy vs current state)
- **Status:** pending

## Key Questions

1. Is the queue-based summarization (external script interface) the right long-term approach?
2. Should CI run on GitHub Actions or stay manual?
3. What's the v2.0 vision — more MCP tools? different embedding models?

## Decisions Made

| Decision | Rationale |
| -------- | --------- |
| Xenova/all-MiniLM-L6-v2 for embeddings | Runs locally, no API calls, 384-dim is compact |
| SQLite + sqlite-vec | Single file DB, no server, vector search built in |
| External script for summarization | Decoupled from embedding model, supports queue/ollama/claude |
| SessionStart hook for sync | Background sync on session start, non-blocking |
| Exclusion markers in conversation | Let users opt out of indexing specific chats |

## Errors Encountered

| Error | Attempt | Resolution |
| ----- | ------- | ---------- |
| MCP server startup (bash vs node) | v1.0.13 | Added mcp-server-wrapper.js |
| better-sqlite3 Node.js version | v1.0.7 | postinstall rebuild script |
| Duplicate hooks in plugin.json | v1.0.11 | Removed duplicate entry |
