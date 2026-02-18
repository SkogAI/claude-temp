#!/bin/bash
# PostToolUse hook: auto-format and lint shell files after Edit/Write
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# bail if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# only act on shell files
case "$FILE_PATH" in
  *.sh | *.bash | *.bats) ;;
  *) exit 0 ;;
esac

# bail if file doesn't exist (deleted, etc)
[[ -f "$FILE_PATH" ]] || exit 0

# format with shfmt (2-space indent, binary ops start of line, case indent)
if command -v shfmt &>/dev/null; then
  shfmt -i 2 -bn -ci -w "$FILE_PATH" 2>/dev/null || true
fi

# lint with shellcheck (informational only, never blocks)
if command -v shellcheck &>/dev/null; then
  ISSUES=$(shellcheck -f gcc -S warning "$FILE_PATH" 2>/dev/null || true)
  if [[ -n "$ISSUES" ]]; then
    echo "shellcheck warnings in $FILE_PATH:"
    echo "$ISSUES"
  fi
fi

exit 0
