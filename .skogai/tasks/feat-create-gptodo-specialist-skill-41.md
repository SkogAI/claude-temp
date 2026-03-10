---
state: new
created: 2026-03-10
tracking: ["https://github.com/SkogAI/claude/issues/41"]
tags: ["enhancement", "github"]
---

# feat: create gptodo specialist skill

**Source**: [Github #41](https://github.com/SkogAI/claude/issues/41)

## Description

## Parent

Part of #40 (skogai-git orchestrator epic)

## Task

Create `skills/gptodo/SKILL.md` — a specialist skill for gptodo task management.

## Should cover

- CLI location (`~/.local/bin/gptodo`) and required env (`GPTODO_TASKS_DIR`)
- Command reference: `import`, `fetch`, `sync`, `list`, `check`, `add`, `edit`, `spawn`
- Import workflow: `gptodo import --source github --repo <owner/repo>`
- Spawn patterns: `gptodo spawn <task> --backend claude` (worktree creation, tmux)
- Task file format

## Notes

*Imported from external tracker. See source link for full context.*
