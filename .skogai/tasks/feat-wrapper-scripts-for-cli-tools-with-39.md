---
state: new
created: 2026-03-10
tracking: ["https://github.com/SkogAI/claude/issues/39"]
tags: ["enhancement", "github"]
---

# feat: wrapper scripts for CLI tools with visible output

**Source**: [Github #39](https://github.com/SkogAI/claude/issues/39)

## Description

## Problem

Some CLI tools (e.g. `wt merge`) produce no visible output on success, making it hard for Claude Code to know what happened. This leads to confusion — running the same command twice, missing that a commit was already created, etc.

## Desired solution

Create wrapper scripts (in `./scripts/` added to PATH, and/or as argc commands) that wrap common CLI tools and ensure they always produce visible output. The wrappers should:

1. **Always echo what happened** — even on success (e.g. "c

## Notes

*Imported from external tracker. See source link for full context.*
