# RTK Token Optimization

**Context**: Using RTK (Rust Token Killer) to minimize token consumption from command outputs.

## Commands to Optimize

Always use RTK wrapper for these high-verbosity commands:

### Git Operations (92.3% avg reduction)
- `rtk git log` instead of `git log`
- `rtk git status` instead of `git status`
- `rtk git diff` instead of `git diff`

### File Operations (69.4% avg reduction)
- `rtk find "*.md" .` instead of `find . -name "*.md"`
- `rtk read <file>` instead of `cat <file>` (for large files >10K lines)

### DO NOT use RTK for:
- `ls` (worse output: -274% token increase)
- `grep` (buggy as of v0.2.0)

## Token Savings Target

**Baseline**: ~150K tokens per 30-min session
**With RTK**: ~45K tokens (70% reduction)

## Installation

RTK is installed system-wide: `/usr/local/bin/rtk`

## Verification

Check RTK availability:
```bash
rtk --version  # Should show: rtk 0.2.0
```

## When NOT to use RTK

- Quick exploration (1-2 commands): overhead not worth it
- Already using tools like Grep/Read (Claude native tools are optimized)
- Small outputs (<100 chars): minimal gain

## Automation

Use RTK automatically via hook (see `.claude/hooks/bash/rtk-wrapper.sh`)
