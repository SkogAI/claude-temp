# Session Summary — 2026-03-02

## What This Session Was

Fresh rebuild of SkogAI. User and Claude exploring the dual-git architecture together, identifying what's real vs cached, and cleaning up stale artifacts.

## What Got Done

### Cleanup
- Deleted `global/skills/` (fleet-memory, nelson, skogai-agent-prompting, skogai-argc, skogai-routing)
- Deleted `projects/skogai-core/` (plugin scaffold)
- Deleted `~/.claude/skills/` (stale cached skills)
- Deleted failed csync-check.sh script and its artifacts (snapshots/, /tmp files)
- Created `CLAUDE.md` at repo root (needs updating to remove references to deleted things)
- Created `projects/claude-welcome-tour/CLAUDE.md` as working memory

### Key Discoveries

**Cache pollution is the core problem.** Claude's Anthropic-side cache serves deleted files as current. Skills deleted weeks ago were read as real during /init. No way to audit cache vs reality from user's side — only Claude can see the cache.

**Bare repo observability is thorough.** The bare repo records: debug telemetry, every user message verbatim, full conversation transcripts (including thinking blocks with crypto signatures), shell history, screen dimensions, API handshakes, permission decisions. All committed by csync on every message.

**The `/diff` size problem.** A 7736-line tool-results file (`bisf9iew9.txt`) from the failed csync-check script was being synced into the local repo, making Claude Code's `/diff` command choke. File lives at `global/projects/-home-skogix-claude/7879c7bc-abb6-4432-8022-25a59da10510/tool-results/bisf9iew9.txt` — still needs deleting.

**Git diff format details.** The `i/` and `w/` prefixes (instead of `a/`/`b/`) come from `diff.mnemonicPrefix = true` in git config. `i/` = index (committed state), `w/` = working tree (current disk). The funcname heuristic in `@@` headers grabs random nearby lines for non-code files like zsh_history.

**Color codes as provenance.** In bare repo diff output, `[32m` (green) lines = new since last csync. Uncolored = already committed/on Anthropic's side.

### Plan: Filter bare repo log noise

**Problem:** Bare repo log output is 6500+ lines of noise (debug, transcripts, tool-results, zsh_history).

**Fix:** Add git pathspec exclusions to bare repo log commands:
```
-- ':!.claude/debug' ':!.claude/projects' ':!.zsh_history' ':!snapshot-zsh-*'
```
Scripts have since been refactored into `csync-rsync.sh`, `csync-git.sh`, `csync-watch.sh`.

## Git Repos
- **Bare repo** (`/mnt/sda1/claude-global.git`, work-tree `$HOME`) — accessed via inline `git --git-dir=... --work-tree=...` in `csync-git.sh`
- **Local repo** (`~/claude/`) — regular `git`

## Still To Do
- [ ] Delete the bloating tool-results file (`bisf9iew9.txt`)
- [ ] Set up ~/skogai/
- [ ] Clarify or remove rtk/beads/br references
- [ ] Explore .skogai/todo/ (archived project docs, bin scripts)
- [ ] Check skogapi/ status

## Mistakes Made (learn from these)
- Overengineered csync-check.sh (97 lines with flags/subcommands when a simple diff was asked for)
- Didn't understand the fundamental asymmetry: user CANNOT see Anthropic's cache, only Claude can
- Ran `tree ~ > /tmp/a` literally when user was explaining a concept
- Multiple denied rewrites because of over-complication
- Patronizing explanations of things the user built
- User was on mobile — brevity matters

## Design Principles Established
- Stale context is worse than no context
- Archaeology before generation (recover existing work before inventing)
- Small iterations, focused agents, constrained workflows
- After ~500 tokens of explanation, stop
- Don't overengineer. One command. One thing.
