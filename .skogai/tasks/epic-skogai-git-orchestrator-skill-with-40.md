---
state: new
created: 2026-03-10
tracking: ["https://github.com/SkogAI/claude/issues/40"]
tags: ["enhancement", "github"]
---

# epic: skogai-git orchestrator skill with specialist subagents

**Source**: [Github #40](https://github.com/SkogAI/claude/issues/40)

## Description

## Summary

Create a unified `skogai-git` skill that orchestrates three specialist subagent skills for git-related operations: **gptodo** (task management), **gita** (multi-repo management), and **worktrunk** (worktree management).

## Problem

- `gita` and `worktrunk` have skills but they're standalone — no coordination between them
- `gptodo` has no skill at all (only documented in auto memory and as a package in the gptme skill)
- Common workflows span multiple tools (e.g. "ship this" = wt me

## Notes

*Imported from external tracker. See source link for full context.*
