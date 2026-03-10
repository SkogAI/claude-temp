---
state: new
created: 2026-03-10
tracking: ["https://github.com/SkogAI/claude/issues/43"]
tags: ["enhancement", "github"]
---

# feat: create/refine worktrunk specialist skill

**Source**: [Github #43](https://github.com/SkogAI/claude/issues/43)

## Description

## Parent

Part of #40 (skogai-git orchestrator epic)

## Task

Ensure `skills/worktrunk/` exists as a proper specialist skill for worktree management.

## Current state

Worktrunk has a skill registered in the system (triggers on "worktrunk" mentions) but need to verify depth and subagent-readiness.

## Should cover

- Command reference: `wt list`, `wt merge`, `wt remove`, `wt create`, `wt switch`
- `wt list` output interpretation (symbols: `@` current, `+` checked out, `⚑` dirty, `⊂` merged, `

## Notes

*Imported from external tracker. See source link for full context.*
