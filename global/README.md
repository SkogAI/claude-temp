# global/

Symlinks into `~/.claude/` — the CLI's runtime home. Everything here points at the real files the CLI owns and writes to. Changes show up in both repos' git diffs.

## Bare repo

`/mnt/sda1/claude-global.git` — bare git repo tracking `~/.claude/` contents.

- work tree: `$HOME`
- wrapper: `./scripts/cgit.sh` (passes `--git-dir` and `--work-tree`)
- auto-commits via `./scripts/csync.sh` on every message (UserPromptSubmit hook)
- purpose: observability — see exactly what the CLI writes, when, and how much

### exclude (info/exclude)

Symlinked here as `./global/exclude`. Current excludes:

- `.claude/plugins/marketplaces/claude-plugins-official` — embedded git repo, managed by CLI
- `.claude.json.backup*` — backup copies of .claude.json created every session, high churn

Everything else is tracked intentionally — debug, cache, shell-snapshots, all of it. The bare repo is for understanding, not for keeping clean.

## Symlinks

| local | target |
|-------|--------|
| `settings.json` | `~/.claude/settings.json` |
| `projects/` | `~/.claude/projects/` |
| `plans/` | `~/.claude/plans/` |
| `todos/` | `~/.claude/todos/` |
| `plugins/blocklist.json` | `~/.claude/plugins/blocklist.json` |
| `plugins/known_marketplaces.json` | `~/.claude/plugins/known_marketplaces.json` |
| `exclude` | `/mnt/sda1/claude-global.git/info/exclude` |

## Scripts

| script | what |
|--------|------|
| `./scripts/cgit.sh` | bare repo git wrapper |
| `./scripts/csync.sh` | auto-commit both repos (bare + home) |
| `./scripts/clog.sh` | show recent commits from both repos |
