# Claude Welcome Tour — Working Notes

## Dual Git Architecture

**Local repo** (`git` in `~/claude/`):
- 7,365 tracked files — curated project content
- Projects, global/ symlinks, scripts, .skogai/ context
- Bulk comes from global/projects/ (conversation transcripts) and global/usage-data/

**Bare repo** (`claude-dotfiles`, git-dir `/mnt/sda1/claude-global.git`, work-tree `$HOME`):
- Raw observability of everything Claude CLI writes at runtime
- Tracks: .claude/debug/, history.jsonl, projects/*.jsonl, plugins/, settings, plans, shell-snapshots
- Also tracks .zsh_history
- csync.sh auto-commits both repos on every message (UserPromptSubmit hook)

**Key insight**: local repo = curated, bare repo = raw runtime. Both stay in lockstep via csync.

## Git Wrappers

- `claude-dotfiles` — use for bare repo operations (replaces cgit.sh)
- `git` — use for local ~/claude/ repo
- `skogai-dotfiles` — exists but not yet explored (for ~/skogai/ presumably)

## Cleanup Done

- Deleted: global/skills/, projects/skogai-core/, ~/.claude/skills/
- User handles all git commits manually during tour

## Key Insight: Cache Pollution & Plan Mode

**Problem:** Claude's Anthropic-side cache serves stale files as if current. Skills deleted weeks ago, old configs, ghost project scaffolds — all read as "real." This led to the /init CLAUDE.md documenting things that didn't exist.

**Why plan mode matters:** Read-only mode means all reads/writes go through cache, never touching the user's filesystem directly. Both sides accumulate git diffs independently. Changes only flow to disk when plan mode exits. This is controlled context flow.

**Why explicit deletes:** Force cache invalidation by running actual rm + verify with read-tool. Only way to make cache agree with reality for specific paths.

**Design principle for SkogAI:** Stale context is worse than no context. Context that was true once but isn't anymore generates confident wrong answers. This is the core motivation for the fresh rebuild — no way to audit what's real vs cached ghost data in the old setup.

## Still To Explore

- ~/skogai/ and skogai-dotfiles — will set up together
- rtk, beads/br — clarify or remove references
- .skogai/ contents — "probably doesn't make sense yet"
- skogapi/ — FastAPI service, status unknown
- Installed 3 official plugins this session (claude-code-setup, claude-md-management, skill-creator)
