# Auto Memory

## Tools & Workflows

- **gptodo**: Task management CLI at `~/.local/bin/gptodo`. Tasks dir: `/home/skogix/claude/.skogai/tasks`. Always set `GPTODO_TASKS_DIR=/home/skogix/claude/.skogai/tasks` when running. Key commands: `import --source github --repo <owner/repo>`, `fetch --all`, `sync --update --use-cache`, `list`, `check`.
- **gptodo import bug**: Writes unquoted YAML dates (`created: 2026-03-06`) — fix with `sed -i 's/^created: \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$/created: "\1"/' tasks/*.md`. Tracked: SkogAI/dot-skogai#6.
- **wt (worktrunk)**: Git worktree management. `wt list`, `wt merge`, `wt remove`. User prefers `wt merge && git push` for shipping. Note: `wt merge` produces no visible output on success — always verify with `git log -1` after. `wt remove <branch-name>` uses the full branch name (e.g. `worktree-swift-oak-dqkp`), not the short suffix. `wt switch <branch>` to switch to existing remote branch (creates local tracking + worktree). `wt switch --create <branch>` for new branch. `wt switch -x claude -- 'prompt'` to launch Claude in worktree. Worktrees land in `~/.claude/worktrees/`.
- **wt + gptodo interop**: Both tools read git's native worktree tracking — no separate state. `wt` creates/switches/merges, `gptodo worktree` adds task-aware operations. `gptodo worktree list` and `gptodo worktree status <full-path>` work on wt-created worktrees automatically.
- **claude-memory**: Plugin installed via skogai-marketplace. MCP server `episodic-memory` provides search. CLI: `claude-memory sync`, `claude-memory index`, `claude-memory stats`. Summaries show in search when >300 char limit was removed.
- **queue**: Async job queue CLI. Jobs fail inside Claude Code sessions due to `CLAUDECODE` env var — bypass with `CLAUDECODE= <command>`.
- **gptme-contrib**: Full monorepo mapped in `skills/gptme/` skill (SKILL.md + 14 references). Key CLIs: `gptodo`, `gptme-sessions`, `gptme-runloops`, `summarize`. Use `--backend claude` for CC integration. Nesting pattern: strip `CLAUDECODE` + `CLAUDE_CODE_ENTRYPOINT` env vars.
- **gptme-sessions**: `signals <trajectory>` extracts tool calls/commits/grade/tokens from CC `.jsonl`. `post-session --harness claude-code` records. `discover` finds all trajectories in `~/.claude/projects/`.
- **gptme-runloops**: `autonomous --backend claude-code` for solo loops, `team --backend claude-code` for coordinator pattern. CC backend can't restrict tools (TeamRun limitation).
- **Claude Code Agent Teams**: TeamCreate + Agent tool spawns teammates in tmux. TaskCreate for shared task list. SendMessage for coordination. TeamDelete to clean up. Agents go idle between turns (normal). Always shutdown teammates when done.
- **gita**: Multi-repo git manager. `gita ll` for overview, `gita fetch` across all, `gita super <repo> <cmd>` for targeted git ops, `gita ll <group>` for group status. Groups: `web` (skogai-web repos), `claude-home` (5 claude workspace repos), `src` (14 ~/.local/src repos), `skogai` (all 19 — claude-home + src combined). Config at `~/.config/gita/`. Use `gita ll skogai` for full dashboard, `gita ll claude-home` for workspace only. Note: `src/claude-memory` and `src/gptme-contrib` are the ~/.local/src copies (auto-prefixed to avoid collision with ~/claude/projects/ copies).

## Plugin System

- **Adding plugins to marketplace**: Use `source: {"source": "github", "repo": "owner/repo"}` in marketplace.json for external repos. Don't use submodules inside marketplace — let the plugin system manage fetching.
- **Marketplace name collisions**: claude-memory's own marketplace.json declares name `skogai-marketplace` — adding it as a separate marketplace overwrites the real one. Always add external plugins as entries in the existing marketplace instead.
- **strict: false**: Use when marketplace entry defines everything and plugin has its own plugin.json that would conflict.

## Project Structure

- `projects/` — git submodules for active development repos (claude-memory, gptme-contrib)
- `marketplaces/` — plugin marketplace submodules (skogai-marketplace, worktrunk)
- `.skogai/tasks/` — gptodo task files synced from GitHub issues
- `.skogai/state/` — cached state (issue-cache.json, sessions/)
- `.skogai/.worktrees` — symlink to `.claude/worktrees` (gptodo worktree target)
- `skills/gptme/` — gptme-contrib domain expertise skill (SKILL.md + 14 reference files)
- `skills/gita/` — gita multi-repo management skill (SKILL.md + symlinked config/)

## User Preferences

- Don't add submodules inside marketplace repos — marketplace manages its own plugin fetching
- Run commands as told — don't add `--help` checks before running user's exact command
- Ship via `wt merge && git push`
- GitHub issues first, then `gptodo import` to pull locally
