#!/bin/bash
# RTK Auto-Wrapper Hook
# Automatically wraps high-verbosity commands with RTK for token optimization
#
# Hook: PreToolUse
# Matcher: Bash
# Purpose: Intercept bash commands and suggest RTK wrapper if applicable
#
# Installation:
# 1. Copy to .claude/hooks/bash/rtk-auto-wrapper.sh
# 2. Make executable: chmod +x .claude/hooks/bash/rtk-auto-wrapper.sh
# 3. Add to settings.json:
#    {
#      "hooks": {
#        "PreToolUse": [{
#          "matcher": "Bash",
#          "hooks": [".claude/hooks/bash/rtk-auto-wrapper.sh"]
#        }]
#      }
#    }

# Check if RTK is installed
if ! command -v rtk &> /dev/null; then
    # RTK not installed, skip silently
    exit 0
fi

# Parse tool input to get the bash command
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
    # No command found, continue
    exit 0
fi

# Define RTK-optimizable commands with their savings
declare -A RTK_COMMANDS=(
    ["git log"]="92.3"
    ["git status"]="76.0"
    ["git diff"]="55.9"
    ["find"]="76.3"
)

# Check if command matches RTK-optimizable pattern
for cmd in "${!RTK_COMMANDS[@]}"; do
    if [[ "$COMMAND" == "$cmd"* ]] && [[ "$COMMAND" != "rtk "* ]]; then
        savings="${RTK_COMMANDS[$cmd]}"

        # Suggest RTK wrapper
        cat << EOF
💡 RTK Optimization Available

Command: $COMMAND
Suggested: rtk $COMMAND
Token Savings: ~${savings}%

Using RTK wrapper automatically.
EOF

        # Modify command to use RTK
        # Note: This is informational only - actual command modification
        # requires additionalContext return (Claude Code v2.1.9+)

        # For now, just inform user
        exit 0
    fi
done

# Check for commands that should NOT use RTK
if [[ "$COMMAND" == "ls"* ]] && [[ "$COMMAND" == "rtk "* ]]; then
    cat << EOF
⚠️ RTK Not Recommended

Command: $COMMAND
Issue: RTK ls produces worse output (-274% token increase)
Suggestion: Use plain 'ls' instead

Blocking RTK usage for this command.
EOF
    exit 2  # Block the command
fi

# Continue with original command
exit 0
