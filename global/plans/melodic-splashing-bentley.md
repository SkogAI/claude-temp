# Plan: inotifywait → rsync → git auto-sync

## Context

Claude Code holds FDs on files in `~/.claude/`, deletes+rewrites them constantly, and spawns `.backup.N` files. This means:
- `~/.claude/` can't be a normal git repo (FD conflicts)
- Symlinks break (delete+rewrite destroys them)
- rsync is the only reliable snapshot mechanism

Two independent repos need syncing:
- **Bare repo** (`/mnt/sda1/claude-global.git`, work-tree: `$HOME`) — tracks raw `~/.claude/` state
- **Normal repo** (`~/claude/`) — projects, scripts, docs + rsynced copies of some `~/.claude/` subdirs in `global/`

These are NOT the same data. The bare repo is the authoritative record of `~/.claude/`. The normal repo is the project workspace.

## Architecture

Three scripts, one service:

```
scripts/
  csync-rsync.sh   — rsync ~/.claude/ → ~/claude/global/
  csync-git.sh     — git add + commit + push for both repos
  csync-watch.sh   — inotifywait loop, calls the above

systemd/
  csync.service    — systemd user service running csync-watch.sh
```

## Scripts

### `scripts/csync-rsync.sh`

Snapshots `~/.claude/` subdirs into `~/claude/global/`. Nothing else.

```bash
#!/usr/bin/env bash
set -euo pipefail

for d in cache plans memories teams tasks projects transcripts session-env usage-data commands agents skills hooks; do
  [ -d "$HOME/.claude/$d" ] && rsync -a "$HOME/.claude/$d/" "$HOME/claude/global/$d/"
done
```

### `scripts/csync-git.sh`

Commits and pushes both repos. Uses flock so concurrent calls serialize.

```bash
#!/usr/bin/env bash
set -euo pipefail

LOCK="/tmp/csync-git.lock"
exec 9>"$LOCK"
flock 9

TS=$(date +%H:%M:%S)
BARE=/mnt/sda1/claude-global.git

# bare repo — tracks ~/.claude/
git --git-dir="$BARE" --work-tree="$HOME" add "$HOME/.claude/"
git --git-dir="$BARE" --work-tree="$HOME" add -u
git --git-dir="$BARE" --work-tree="$HOME" commit -m "auto-sync $TS" --no-verify || true
git --git-dir="$BARE" --work-tree="$HOME" push || true

# local repo — tracks ~/claude/
git -C "$HOME/claude" add -A
git -C "$HOME/claude" commit -m "auto-sync $TS" --no-verify || true
git -C "$HOME/claude" push || true
```

Note: blocking flock (not `-n`). Concurrent calls wait instead of being dropped — every change gets versioned.

### `scripts/csync-watch.sh`

The watcher. Runs inotifywait in monitor mode, calls rsync then git on every event.

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

inotifywait -m -r -e modify,create,delete,move "$HOME/.claude/" |
while read -r; do
  "$SCRIPT_DIR/csync-rsync.sh"
  "$SCRIPT_DIR/csync-git.sh"
done
```

### `systemd/csync.service`

```ini
[Unit]
Description=Claude auto-sync watcher
After=network.target

[Service]
Type=simple
ExecStart=/home/skogix/claude/scripts/csync-watch.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
```

Install: `systemctl --user enable --now csync.service`

## Files

| File | Action |
|------|--------|
| `scripts/csync-rsync.sh` | Create |
| `scripts/csync-git.sh` | Create |
| `scripts/csync-watch.sh` | Create |
| `systemd/csync.service` | Create |
| `scripts/fetch-docs.sh` | Already exists |

## Verification

1. Run `csync-rsync.sh` — check `~/claude/global/` has fresh copies
2. Run `csync-git.sh` — check both repos have new commits
3. Run `csync-watch.sh` — touch a file in `~/.claude/`, verify commit appears
4. `systemctl --user start csync.service` — verify it stays running and syncs on changes
