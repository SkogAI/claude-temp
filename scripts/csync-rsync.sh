#!/usr/bin/env bash
set -euo pipefail

for d in cache plans memories teams tasks projects transcripts session-env usage-data commands agents skills hooks; do
  [ -d "$HOME/.claude/$d" ] && rsync -a "$HOME/.claude/$d/" "$HOME/claude/global/$d/"
done
