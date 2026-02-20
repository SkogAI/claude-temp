# Claude Code Worktree Cleanup Investigation

Explored how claude code's `--worktree` / `-w` flag and `EnterWorktree` tool actually work in practice.

## Key findings

**Path mismatch between codepaths:**
- `-w` CLI flag → `<repo>/.worktrees/<name>`
- `EnterWorktree` tool → claims `.claude/worktrees/<name>` in output
- Despite the mismatch, `EnterWorktree` correctly finds and reuses existing worktrees by name

**Cleanup is broken or unimplemented:**
- Tool docs promise "on session exit, prompted to keep or remove the worktree"
- In practice, worktrees accumulate with no cleanup prompt
- Likely cause: cleanup hook looks in wrong path, or only fires for `EnterWorktree`-created worktrees

**EnterWorktree is context-unaware:**
- Available as a tool even when already inside a worktree
- Its own docs say "must not already be in a worktree" but this isn't enforced

**Beads DB is per-worktree:**
- sqlite DB doesn't carry over — need `br sync --import-only` in new worktrees
- `br sync --flush-only` will refuse to export empty DB over existing JSONL (safety check works correctly)

## Verdict

The worktree feature is half-baked. Creation works, lifecycle management doesn't. The obvious improvement would be hooking session close to `git worktree remove` — something skogix has already implemented manually before.
