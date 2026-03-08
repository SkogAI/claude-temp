# Findings & Decisions

## Architecture

- **Language**: Python monorepo (uv workspace)
- **Size**: 76K lines, 493 files, 802 commits
- **Structure**: packages/ (12), plugins/ (13), skills/ (7), scripts/, tools/
- **CI**: 6 GitHub Actions workflows (test-packages, test-plugins, test-integration, dashboard, publish, pre-commit)

## Package Maturity

| Package | Readiness | Tests | Notes |
|---------|-----------|-------|-------|
| gptodo | Production-ready | 7 files | Core task management + agent spawning |
| gptme-sessions | Production-ready | 3 files | Session tracking, JSONL storage, model normalization |
| gptme-runloops | Production-ready | 8 files | Autonomous/team/monitoring loops |
| gptme-activity-summary | Production-ready | 7 files | Journals, GitHub, sessions, email summarization |
| gptmail | Beta | ? | Email/message handling |
| gptme-lessons-extras | Stable | - | Lesson validation, Click CLI migration complete |
| gptme-contrib-lib | Gap | 0 files | Shared base — no tests, excluded from mypy |
| gptme-voice | Beta | - | OpenAI Realtime voice interface |
| gptme-whatsapp | Beta | - | WhatsApp via whatsapp-web.js |

## Dependency Graph

```
gptme-contrib-lib (shared base — Click, Pydantic, YAML)
  ↑
gptme-sessions (standalone analytics)
  ↑
gptme-activity-summary (depends on gptme + sessions)

gptme-runloops (depends on gptme for GptmeExecutor)
  ↑
gptodo (task mgmt, uses runloops for spawn)

gptme-dashboard, gptmail, gptme-voice, gptme-whatsapp (standalone)
```

## Plugin Status

- **10 with tests**: ace, attention-tracker, claude-code, consortium, gptodo, gupp, hooks-examples, imagen, lsp, ralph
- **5 never validated in CI**: ace, attention-tracker, claude-code, lsp, warpgrep
- **3 without tests**: retrieval, warpgrep, wrapped

## Claude Code Integration Points

- `gptodo spawn <task> --backend claude` — spawns CC subagents in tmux
- `gptme-runloops autonomous/team --backend claude-code`
- `gptme-sessions signals <trajectory>` — parses CC .jsonl
- Nesting pattern: strip `CLAUDECODE` + `CLAUDE_CODE_ENTRYPOINT` env vars
- Limitation: CC backend can't restrict tools in team mode

## Recent Development Focus

- Dashboard expansion (gh-pages, per-skill detail pages)
- Click CLI standardization (13 CLIs migrated)
- CI optimization (filter test matrix to affected packages)
- Pre-commit hooks improvements
