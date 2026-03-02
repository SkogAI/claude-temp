#!/usr/bin/env bash

cd /home/skogix/skogai || exit

# --system-prompt="" \
# --resume="claude-code-settings-and-envs" \
claude \
  --worktree="claude-code-settings-and-envs" \
  --setting-sources="project" \
  --settings="/home/skogix/.claude/settings.json" \
  --plugin-dir="/home/skogix/.local/src/marketplace" \
  --permission-mode="plan" \
  --mcp-config="/home/skogix/skogai/config/mcp.json" \
  --effort="high" \
  --dissallowedTools="NotebookEdit Computer WebSearch WebFetch" \
  --append-system-prompt='[$claude]hi claude![$/claude]' \
  --add-dir="/home/skogix/skogai" \
  --allow-dangerously-skip-permissions \
  --mcp-debug \
  --strict-mcp-config \
  --tmux \
  --no-chrome
