#!/usr/bin/env bash
# Auto-commit changes in both claude repos

TS="$(date +%H:%M:%S)"

# sync important dirs to ./global/
# rsync ~/.claude/projects/ ./global/projects/
for dir in plans memories teams tasks projects transcripts session-env usage-data commands agents skills hooks; do
  [ -d ~/.claude/$dir ] && rsync -a --delete ~/.claude/$dir/ ./global/$dir/
done

# bare repo: everything in ~/.claude/
./scripts/cgit.sh add ~/.claude/
./scripts/cgit.sh commit -m "auto-sync $TS" --no-verify || true

# home repo
git add -A
git commit -m "auto-sync $TS" --no-verify || true
