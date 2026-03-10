# Auto Memory

## Git Branching Model

See [git-branching-model.md](git-branching-model.md) for full details. Summary:
- `master` = only branch that talks to origin. All PRs target master.
- Feature branches = temporary worktrees. Push branch, PR against master. Clean up after merge.
- No develop branch. Worktrees go directly to master via PR.
- `wt merge` for trivial local fast-forwards into master, then `git push`.
- `wt config state default-branch set master`.

## Claude Worktree Launch (standard method)

`claude --worktree <name> --tmux=classic` — the standard way to start a Claude Code session. Creates a git worktree + tmux session in one command. Worktree lands in `~/.claude/worktrees/<name>/`, branch becomes `worktree-<name>`. Use this for all new work sessions. If a worktree with the same name already exists, it reuses it (no error, no duplicate).

**Workflow from worktree to shipped code:**
1. Pick an issue
2. `claude --worktree <name> --tmux=classic` — start session
3. Work + commit in worktree branch
4. `git push -u origin HEAD` + `gh pr create --base master`
5. After PR merges, clean up worktree (`wt remove` or `git worktree remove`)

## Claude Worktree Launch (standard method)

`claude --worktree <name> --tmux=classic` — the standard way to start a Claude Code session. Creates a git worktree + tmux session in one command. Worktree lands in `~/.claude/worktrees/<name>/`, branch becomes `worktree-<name>`. Use this for all new work sessions. If a worktree with the same name already exists, it reuses it (no error, no duplicate).

**Workflow from worktree to shipped code:**
1. Pick an issue
2. `claude --worktree <name> --tmux=classic` — start session
3. Work + commit in worktree branch
4. `wt merge` — merges worktree branch into develop, auto-removes worktree+branch (verify with `git log -1`)
6. Develop accumulates changes from multiple worktrees
7. PR from develop → master when ready to ship a batch (`gh pr create`)

## Tools & Workflows

- **gptodo**: Task management CLI at `~/.local/bin/gptodo`. `GPTODO_TASKS_DIR` is set in the shell profile — never prefix it manually. Key commands: `import --source github --repo <owner/repo>`, `fetch --all`, `sync --update --use-cache`, `list`, `check`.
- **gptodo import bug**: Writes unquoted YAML dates (`created: 2026-03-06`) — fix with `sed -i 's/^created: \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$/created: "\1"/' tasks/*.md`. Tracked: SkogAI/dot-skogai#6.
- **wt (worktrunk)**: Git worktree management. `wt list`, `wt merge`, `wt remove`. `wt merge` works from inside or outside the worktree (auto-detects), shows output like `Merged to develop (1 commit, 1 file, +1)`, auto-removes worktree+branch, switches cwd to `~/claude`. Single commits fast-forward; multiple squash. Verify with `git log -1`. `wt remove <branch-name>` uses the full branch name (e.g. `worktree-swift-oak-dqkp`), not the short suffix. `wt switch <branch>` to switch to existing remote branch (creates local tracking + worktree). `wt switch --create <branch>` for new branch. `wt switch -x claude -- 'prompt'` to launch Claude in worktree. Worktrees land in `~/.claude/worktrees/`. `wt config state default-branch` may get cleared between sessions — re-set with `wt config state default-branch set develop`.
- **wt + gptodo interop**: Both tools read git's native worktree tracking — no separate state. `wt` creates/switches/merges, `gptodo worktree` adds task-aware operations. `gptodo worktree list` and `gptodo worktree status <full-path>` work on wt-created worktrees automatically.
- **claude-memory**: Plugin installed via skogai-marketplace. MCP server `episodic-memory` provides search. CLI: `claude-memory sync`, `claude-memory index`, `claude-memory stats`. Summaries show in search when >300 char limit was removed.
- **queue**: Async job queue CLI. Jobs fail inside Claude Code sessions due to `CLAUDECODE` env var — bypass with `CLAUDECODE= <command>`.
- **gptme-contrib**: Full monorepo mapped in `skills/gptme/` skill (SKILL.md + 14 references). Key CLIs: `gptodo`, `gptme-sessions`, `gptme-runloops`, `summarize`. Use `--backend claude` for CC integration. Nesting pattern: strip `CLAUDECODE` + `CLAUDE_CODE_ENTRYPOINT` env vars.
- **gptme-sessions**: `signals <trajectory>` extracts tool calls/commits/grade/tokens from CC `.jsonl`. `post-session --harness claude-code` records. `discover` finds all trajectories in `~/.claude/projects/`.
- **gptme-runloops**: `autonomous --backend claude-code` for solo loops, `team --backend claude-code` for coordinator pattern. CC backend can't restrict tools (TeamRun limitation).
- **Claude Code Agent Teams**: TeamCreate + Agent tool spawns teammates in tmux. TaskCreate for shared task list. SendMessage for coordination. TeamDelete to clean up. Agents go idle between turns (normal). Always shutdown teammates when done.
- **gita**: Multi-repo git manager. `~/.local/src/` is the single source of truth for all repos. `gita ll` for overview, `gita fetch` across all, `gita super <repo> <cmd>` for targeted git ops, `gita ll <group>` for group status. Groups: `src` (all 17 repos in ~/.local/src/). Config at `~/.config/gita/` → symlinked from `skills/gita/config/` (version-controlled). `gita freeze` captures full state (URLs, paths, branches); restore with `gita clone -f -p freeze.csv`. Note: `-p` (preserve-path) is required to clone into original paths.

## Plugin System

- **Adding plugins to marketplace**: Use `source: {"source": "github", "repo": "owner/repo"}` in marketplace.json for external repos. Don't use submodules inside marketplace — let the plugin system manage fetching.
- **Marketplace name collisions**: claude-memory's own marketplace.json declares name `skogai-marketplace` — adding it as a separate marketplace overwrites the real one. Always add external plugins as entries in the existing marketplace instead.
- **strict: false**: Use when marketplace entry defines everything and plugin has its own plugin.json that would conflict.

## Project Structure

- `projects/` — symlinks to ~/.local/src/ (claude-memory, gptme-contrib, small-hours) + local dirs (argcfile, claude-persona, skogai-context)
- `marketplaces/` — symlinks to ~/.local/src/ (skogai-marketplace → marketplace, worktrunk)
- `.skogai/tasks/` — gptodo task files synced from GitHub issues
- `.skogai/state/` — cached state (issue-cache.json, sessions/)
- `.skogai/.worktrees` — symlink to `.claude/worktrees` (gptodo worktree target)
- `skills/gptme/` — gptme-contrib domain expertise skill (SKILL.md + 14 reference files)
- `skills/gita/` — gita multi-repo management skill (SKILL.md + symlinked config/)

## argc-completions as Claude Code Commands

Pattern for giving Claude Code validated, sandboxed CLI access via argc-completions:
- Completion scripts at `$ARGC_COMPLETIONS_ROOT/completions/<command>.sh` define valid subcommands/args/flags
- Run via `bash $ARGC_COMPLETIONS_ROOT/completions/<command>.sh <subcommand> [args]`
- `argc --argc-eval` validates input BEFORE execution — invalid input gets `exit 1` before any code runs
- Goal: wrap these as PATH commands so Claude calls `gptodo import` instead of raw bash
- Pipeline: `argc --argc-eval script.sh <args> | bash` — eval generates code, pipe executes only if valid
- TODO: create wrapper shims in PATH that strip `.sh`, route through argc eval. New worktree needed.
- Session context: `0638df4d-1216-4823-a61f-4552879d6c31`

## User Preferences

- No submodules — all repos live in ~/.local/src/, symlinked into ~/claude/ where needed
- Idempotency: every operation should be safe to run twice
- Run commands as told — don't add `--help` checks before running user's exact command
- Ship via `wt merge` into develop, then PR from develop → master (`gh pr create --base master`)
- GitHub issues first, then `gptodo import` to pull locally
