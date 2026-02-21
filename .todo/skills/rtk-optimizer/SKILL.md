---
name: rtk-optimizer
description: Optimize command outputs with RTK (Rust Token Killer) for 70% token reduction
version: 1.0.0
tags: [optimization, tokens, efficiency, git]
---

# RTK Optimizer Skill

**Purpose**: Automatically suggest RTK wrappers for high-verbosity commands to reduce token consumption.

## How It Works

1. **Detect high-verbosity commands** in user requests
2. **Suggest RTK wrapper** if applicable
3. **Execute with RTK** when user confirms
4. **Track savings** over session

## Supported Commands

### ✅ High-Value (>70% reduction)
- `git log` → `rtk git log` (92.3% reduction)
- `git status` → `rtk git status` (76.0% reduction)
- `find` → `rtk find` (76.3% reduction)

### ✅ Medium-Value (50-70% reduction)
- `git diff` → `rtk git diff` (55.9% reduction)
- `cat <large-file>` → `rtk read <file>` (62.5% reduction)

### ❌ Not Recommended
- `ls` (worse with RTK: -274%)
- `grep` (buggy in v0.2.0)

## Activation Examples

**User**: "Show me the git history"
**Skill**: Detects `git log` → Suggests `rtk git log` → Explains 92.3% token savings

**User**: "Find all markdown files"
**Skill**: Detects `find` → Suggests `rtk find "*.md" .` → Explains 76.3% savings

## Installation Check

Before first use, verify RTK is installed:
```bash
rtk --version  # Should output: rtk 0.2.0
```

If not installed:
```bash
curl -fsSL "https://github.com/pszymkowiak/rtk/releases/latest/download/rtk-aarch64-apple-darwin.tar.gz" -o rtk.tar.gz
tar -xzf rtk.tar.gz
sudo mv rtk /usr/local/bin/
sudo chmod +x /usr/local/bin/rtk
rm rtk.tar.gz
```

## Usage Pattern

```markdown
# When user requests high-verbosity command:

1. Acknowledge request
2. Suggest RTK optimization:
   "I'll use `rtk git log` to reduce token usage by ~92%"
3. Execute RTK command
4. Track savings (optional):
   "Saved ~13K tokens (baseline: 14K, RTK: 1K)"
```

## Session Tracking

Optional: Track cumulative savings across session:

```bash
# At session end
rtk gain  # Shows total token savings for session
```

## Edge Cases

- **Small outputs** (<100 chars): Skip RTK (overhead not worth it)
- **Already using Claude tools**: Grep/Read tools are already optimized
- **Multiple commands**: Batch with RTK wrapper once, not per command

## Configuration

Enable via CLAUDE.md:
```markdown
## Token Optimization

Use RTK (Rust Token Killer) for high-verbosity commands:
- git operations (log, status, diff)
- file finding
- large file reading
```

## Metrics (Verified)

Based on real-world testing:
- `git log`: 13,994 chars → 1,076 chars (92.3% reduction)
- `git status`: 100 chars → 24 chars (76.0% reduction)
- `find`: 780 chars → 185 chars (76.3% reduction)
- `git diff`: 15,815 chars → 6,982 chars (55.9% reduction)
- `read file`: 163,587 chars → 61,339 chars (62.5% reduction)

**Average: 72.6% token reduction**

## Limitations

- RTK v0.2.0 (8 stars on GitHub, low adoption)
- Some commands buggy (grep returns empty)
- ls command worse with RTK (-274% increase)
- Requires manual installation (not on npm/brew yet)

## Recommendation

**Use RTK for**: git workflows, file finding, large file reading
**Skip RTK for**: ls, grep, small outputs, quick exploration

## References

- RTK GitHub: https://github.com/pszymkowiak/rtk
- Evaluation: `docs/resource-evaluations/rtk-evaluation.md`
- CLAUDE.md template: `examples/claude-md/rtk-optimized.md`
