#!/usr/bin/env bash
# Auto-commit changes in both claude repos

TS="$(date +%H:%M:%S)"

# bare repo: everything in ~/.claude/
./scripts/cgit.sh add ~/.claude/
./scripts/cgit.sh commit -m "auto-sync $TS" --no-verify || true

# home repo
git add -A
git commit -m "auto-sync $TS" --no-verify || true
