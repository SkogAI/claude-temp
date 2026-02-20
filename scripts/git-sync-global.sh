#!/usr/bin/env bash
# Auto-commit tracked changes in both claude repos
# Runs silently — exits 0 even if nothing to commit

TS="$(date +%H:%M:%S)"

# bare repo: ~/.claude/ tracked files
CGG="/home/skogix/claude/scripts/skogai-git-claude-global-git.sh"
$CGG add -u 2>/dev/null
$CGG commit -m "auto-sync $TS" --no-verify 2>/dev/null || true

# home repo: ~/claude/
git -C /home/skogix/claude add -A 2>/dev/null
git -C /home/skogix/claude commit -m "auto-sync $TS" --no-verify 2>/dev/null || true
