#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

inotifywait -m -r -e modify,create,delete,move "$HOME/.claude/" |
while read -r; do
  "$SCRIPT_DIR/csync-rsync.sh"
  "$SCRIPT_DIR/csync-git.sh"
done
