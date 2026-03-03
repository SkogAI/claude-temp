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
