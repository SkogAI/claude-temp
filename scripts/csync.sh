#!/usr/bin/env bash
# Auto-commit tracked changes in both claude repos
# Runs silently — exits 0 even if nothing to commit

TS="$(date +%H:%M:%S)"

# bare repo: tracked files only, new files added manually
./scripts/cgit.sh add -u 2>/dev/null
./scripts/cgit.sh commit -m "auto-sync $TS" --no-verify 2>/dev/null || true

# home repo
git add -A 2>/dev/null
git commit -m "auto-sync $TS" --no-verify 2>/dev/null || true
