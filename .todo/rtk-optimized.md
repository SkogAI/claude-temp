# RTK Token Optimization

**Context**: Using RTK (Rust Token Killer) v0.22.2 to minimize token consumption from command outputs.

## Auto-Rewrite (Active)

RTK's official rewrite hook transparently rewrites Bash commands before execution.
No deny/retry overhead - commands are modified in-place via `updatedInput`.

**Hook**: `~/.claude/hooks/rtk-rewrite.sh` (installed by `rtk init -g`)
**Config**: `~/.claude/settings.json` → `hooks.PreToolUse[Bash]`
**Audit**: `rtk hook-audit` to see rewrite metrics

## Rewritten Commands

| Category | Commands | Savings |
|----------|----------|---------|
| Git | status, log, diff, show, add, commit, push, pull, branch, fetch, stash | 59-92% |
| GitHub | gh pr, gh issue, gh run, gh api, gh release | 26-87% |
| Files | ls, tree, find, grep/rg, cat→read, head→read, diff | 60-95% |
| JS/TS | vitest, tsc, eslint, prettier, playwright, prisma, pnpm, npm | 70-99% |
| Rust | cargo test/build/clippy/check/fmt | 80-90% |
| Python | pytest, ruff, pip | 70-90% |
| Go | go test/build/vet, golangci-lint | 80% |
| Infra | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

## Not Rewritten (pass-through)

- Commands already prefixed with `rtk`
- Heredocs (`<<`)
- Commands not in RTK's supported list (mkdir, chmod, etc.)
- Chained commands where the first command doesn't match

## Meta Commands

```bash
rtk gain              # Cumulative token savings
rtk gain --history    # Per-command history
rtk discover          # Missed opportunities from session history
rtk hook-audit        # Hook rewrite metrics
rtk proxy <cmd>       # Run without filtering (debugging)
```

## Setup

Installed via `rtk init -g --auto-patch`. To reinstall:
```bash
rtk init -g --uninstall   # Remove everything
rtk init -g --auto-patch  # Reinstall
```
