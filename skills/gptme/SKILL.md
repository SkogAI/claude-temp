---
name: gptme-contrib
description: Domain expertise for the gptme-contrib monorepo — packages, plugins, skills, runloops, and CLI tools. Use when working with gptodo, gptme-sessions, gptme-runloops, gptme plugins, or any gptme-contrib package. Routes to per-package references for deep context.
---

<essential_principles>

## gptme-contrib monorepo

76K lines, 493 files. Python monorepo for autonomous AI agent infrastructure.
Three layers: **packages** (installable CLIs), **plugins** (gptme extensions), **skills** (gptme prompt templates).

### Key CLIs (installed via uvx or uv pip)

| CLI | Package | Purpose |
|-----|---------|---------|
| `gptodo` | packages/gptodo | Task management, agent spawning, worktrees |
| `gptme-sessions` | packages/gptme-sessions | Session tracking, signals, analytics |
| `gptme-runloops` | packages/gptme-runloops | Autonomous/team/monitoring loops |
| `gptme-dashboard` | packages/gptme-dashboard | Static dashboard generator |
| `gptmail` | packages/gptmail | Email automation |
| `summarize` | packages/gptme-activity-summary | Activity summarization |
| `gptme-voice-server` | packages/gptme-voice | Voice interface (OpenAI Realtime) |
| `gptme-whatsapp-setup` | packages/gptme-whatsapp | WhatsApp integration |

### Claude Code integration (see references/claude-code-integration.md for full details)

- `gptodo spawn <task> --backend claude` — spawns claude subagents in tmux
- `gptme-runloops autonomous --backend claude-code` — autonomous loop via claude CLI
- `gptme-runloops team --backend claude-code` — coordinator delegates to claude subagents
- `gptme-sessions signals <trajectory>` — parses CC `.jsonl` trajectories natively
- `summarize` — uses `claude -p` as LLM backend for all summarization
- `gptme-whatsapp` — full CC backend with `--resume` for conversation history
- **Nesting pattern**: strip `CLAUDECODE` + `CLAUDE_CODE_ENTRYPOINT` env vars before subprocess
- **Plugins**: `gptme-claude-code` (bridge from gptme→CC), `gptme-gptodo` (delegate to CC subagents)
- **Limitation**: CC backend can't restrict tools (team mode coordinator gets full capabilities)

### Architecture

```
gptme-contrib/
├── packages/          # 12 installable Python packages
│   ├── gptodo/        # task management + agent spawning
│   ├── gptme-runloops/  # autonomous operation loops
│   ├── gptme-sessions/  # session tracking + analytics
│   ├── gptme-contrib-lib/  # shared library
│   ├── gptme-activity-summary/  # journal/github/session summarization
│   ├── gptme-dashboard/  # static workspace dashboard
│   ├── gptmail/       # email automation
│   ├── gptme-voice/   # voice interface
│   ├── gptme-whatsapp/  # whatsapp integration
│   ├── gptme-lessons-extras/  # lesson management
│   ├── run_loops/     # (legacy, replaced by gptme-runloops)
│   ├── lessons/       # (legacy, replaced by gptme-lessons-extras)
│   └── lib/           # (legacy, replaced by gptme-contrib-lib)
├── plugins/           # 13 gptme plugins (Python extensions)
├── skills/            # 7 gptme skills (prompt templates)
├── scripts/           # automation scripts (runs, status, comms)
├── tools/             # standalone tools (google drive, rss, pushover)
├── dotfiles/          # git hooks, install scripts
└── tests/             # cross-package tests
```

### Dependency graph

```
gptme-contrib-lib (shared base)
  ↑
gptme-sessions (standalone analytics)
  ↑
gptme-activity-summary (depends on gptme + gptme-sessions)

gptme-runloops (depends on gptme for GptmeExecutor, standalone for ClaudeCodeExecutor)
  ↑
gptodo (task mgmt, uses runloops executor for spawn)

gptme-dashboard (depends on gptme)
gptmail, gptme-voice, gptme-whatsapp (standalone integrations)
```

</essential_principles>

<intake>

What do you need?

1. Package deep dive (how does X work?)
2. CLI usage (how do I run X?)
3. Plugin development (how to build a gptme plugin?)
4. Integration guidance (how to connect X to claude code?)
5. Runloop setup (how to run autonomous/team loops?)

</intake>

<routing>

| intent | reference |
|--------|-----------|
| gptodo (tasks, spawn, worktree) | references/gptodo.md |
| gptme-sessions (tracking, signals) | references/gptme-sessions.md |
| gptme-runloops (autonomous, team) | references/gptme-runloops.md |
| gptme-activity-summary | references/gptme-activity-summary.md |
| gptme-dashboard | references/gptme-dashboard.md |
| gptmail (email automation) | references/gptmail.md |
| gptme-voice | references/gptme-voice.md |
| gptme-whatsapp | references/gptme-whatsapp.md |
| gptme-contrib-lib (shared) | references/gptme-contrib-lib.md |
| gptme plugins (13 plugins) | references/plugins.md |
| gptme skills (7 skills) | references/skills.md |
| scripts & tools | references/scripts-tools.md |
| claude-code backend specifics | references/claude-code-integration.md |

</routing>
