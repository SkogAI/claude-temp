# Findings & Decisions

## Architecture

- **Framework**: argc (bash argument parser)
- **Entry point**: `/home/skogix/claude/Argcfile.sh`
- **Docs**: `/home/skogix/claude/projects/argcfile/CLAUDE.md`
- **Not a git submodule** — part of main ~/claude repo

## argc Patterns Learned

- `@arg` vs `@option` vs `@flag` have different behaviors
- `[_fn]` validates strictly; `[?_fn]` allows completions only
- Private helpers: prefix with `_` so argc ignores them
- Useful internals: `--argc-script-path`, `--argc-export`, `--argc-eval`

## Current Interface

```bash
argc workspace open [-n name]   # open/create worktree in tmux
argc workspace list             # git worktree list (alias: ls)
argc workspace remove <name>    # remove by name (alias: rm)
argc workspace prune            # prune stale references
argc debug interface [--json]   # show CLI interface
```

## Integration Points

- tmux for worktree sessions
- `claude --worktree` for CC worktree mode
- Potential gptodo integration (`.skogai/.worktrees`)
