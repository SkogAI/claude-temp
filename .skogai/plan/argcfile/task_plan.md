# Task Plan: argcfile — argc-powered workspace manager

## Goal

Clean CLI for managing Claude Code worktrees via argc, replacing raw `claude --worktree` invocations.

## Current Phase

Phase 2 (validation)

## Phases

### Phase 1: Core Implementation (complete)

- [x] argc framework setup (Argcfile.sh at repo root)
- [x] `workspace open [-n name]` — open/create worktree in tmux
- [x] `workspace list` — git worktree list (alias: ls)
- [x] `workspace remove <name>` — remove by name (alias: rm)
- [x] `workspace prune` — prune stale references
- [x] `debug interface [--json]` — show CLI interface
- [x] Document argc patterns and learnings
- **Status:** complete

### Phase 2: Validation

- [ ] Test `workspace open` against real worktree
- [ ] Verify `claude --worktree ""` error handling
- [ ] Test `_in_worktree` detection helper
- **Status:** in_progress

### Phase 3: Polish

- [ ] Shell completions via `argc --argc-completions`
- [ ] Integration with gptodo worktree workflow
- [ ] Consider additional workspace commands (status, switch)
- **Status:** pending

## Key Questions

1. Does `claude --worktree ""` error correctly or silently fail?
2. Should this integrate with gptodo's worktree creation?
3. Is shell completion worth the setup complexity?

## Decisions Made

| Decision | Rationale |
| -------- | --------- |
| argc over raw bash | Validation, help, type safety with minimal boilerplate |
| Argcfile.sh at repo root | argc convention, immediately available |
| Private helpers prefixed with `_` | argc ignores them as commands |
| `git worktree list --porcelain` for parsing | Stable, machine-readable output |
