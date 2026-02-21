# Auto Memory

## Repo Structure

- `~/claude/` — home repo, version-controlled, claude's workspace
- `~/.claude/` — CLI runtime home, owned by the binary
- `~/claude/global/` — symlinks into `~/.claude/` for important files
- `/mnt/sda1/claude-global.git` — bare repo tracking all of `~/.claude/`

## Scripts (run from git root)

- `./scripts/cgit.sh` — bare repo git wrapper
- `./scripts/csync.sh` — auto-commit both repos (hook runs on UserPromptSubmit)
- `./scripts/clog.sh` — show recent commits from both repos

## Key Patterns

- CLI overwrites `~/.claude/settings.json` on session restart — hard links break, use symlinks from `./global/` pointing at `~/.claude/`
- CLI flushes runtime state on exit: `.claude.json`, backups, debug, shell-snapshots
- `info/exclude` in bare repo for gitignore, not a `.gitignore` file
- Never use `-f` flags without explicit reason — rm then ln, not ln -f
- Never pipe to /dev/null without reason — errors are information
- Use existing wrapper scripts, don't inline git commands with raw flags
- `./global/settings.json` is a symlink to `~/.claude/settings.json` — the CLI owns the file
- Symlinks in git are stored as symlink files, not followed — use rsync in csync.sh for dirs needing real tracking
- `./global/projects/` is rsync'd (real files), other `./global/` entries are symlinks (read-only convenience)
- csync.sh rsyncs these dirs from ~/.claude/ to ./global/: projects, memories, teams, tasks, transcripts, session-env, usage-data
- Project settings go in `.claude/settings.json`, global/CLI settings stay in `~/.claude/settings.json`
- `defaultMode: plan` is set in project settings

## User Preferences

- No unnecessary echoes in scripts
- Short script names (`cgit.sh` not `skogai-git-claude-global-git.sh`)
- Scripts use relative paths from git root
- Don't brute-force explore — read context first (journal, beads, docs)
- Git diffs are first-class knowledge artifacts, not just change tracking
