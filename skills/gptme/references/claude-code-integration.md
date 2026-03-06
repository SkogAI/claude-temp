# Claude Code Integration with gptme-contrib

## Overview

gptme-contrib has deep Claude Code (CC) integration across multiple packages. This reference covers every integration point, the nesting pattern, and known limitations.

## The CLAUDECODE Nesting Pattern

The critical pattern enabling CC ↔ gptme-contrib interop is **environment stripping**. When Claude Code runs, it sets `CLAUDECODE=1` and `CLAUDE_CODE_ENTRYPOINT=...`. Any subprocess trying to run `claude` would detect these and refuse to start (anti-nesting protection).

**Solution**: Strip these env vars before spawning `claude`:
```python
run_env = os.environ.copy()
run_env.pop("CLAUDECODE", None)
run_env.pop("CLAUDE_CODE_ENTRYPOINT", None)
```

This pattern appears in:
- `gptme_runloops.utils.executor.ClaudeCodeExecutor`
- `gptodo.subagent` (spawn command)
- `gptme-whatsapp` bridge

Additionally, `stdin=subprocess.DEVNULL` is required for non-interactive `claude -p` usage.

## Package-by-Package Integration

### gptodo (task management)

| Feature | How it uses CC |
|---------|---------------|
| `gptodo spawn <task> --backend claude` | Spawns `claude -p` in tmux session |
| `gptodo spawn --backend claude --type explore` | Sets agent type for CC subagent |
| `gptodo spawn --backend claude --coordination` | Inter-agent coordination via shared DB |
| Worktrees | `gptodo worktree create` + spawn = isolated CC agents per branch |

The spawn command constructs a prompt from the task file, strips CLAUDECODE env, and launches in a tmux pane. Session metadata written to `state/sessions/`.

### gptme-runloops (autonomous loops)

| Feature | How it uses CC |
|---------|---------------|
| `gptme-runloops autonomous --backend claude-code` | Full autonomous loop via CC |
| `gptme-runloops team --backend claude-code` | Coordinator pattern via CC |
| `gptme-runloops monitoring --backend claude-code` | GitHub monitoring via CC |
| `gptme-runloops email --backend claude-code` | Email processing via CC |

`ClaudeCodeExecutor` invokes `claude -p <prompt>` with:
- Optional `--model` override
- Optional `--append-system-prompt` from file
- `capture_output=True` for stdout/stderr capture
- Timeout → exit code 124

**Limitation**: CC backend ignores `tools` parameter — TeamRun's coordinator tool restrictions don't apply. The coordinator gets full CC capabilities instead of being restricted to gptodo+save.

### gptme-sessions (analytics)

| Feature | How it uses CC |
|---------|---------------|
| Trajectory parsing | Native `claude_code` format parser for `.jsonl` files |
| Signal extraction | Tool calls, commits, errors, grade, token usage from CC sessions |
| Session discovery | Auto-discovers CC trajectories at `~/.claude/projects/` |
| Post-session | Records CC sessions with harness=`claude-code` |

CC trajectory format detected by checking for `type: "assistant"` + `content[].type: "tool_use"` pattern. Extracts:
- Tool calls by name (Read, Write, Edit, Bash, etc.)
- Git commits from Bash tool outputs
- File writes from Write/Edit tools
- Token usage (input, output, cache_create, cache_read)
- Model name from usage metadata

### gptme-activity-summary (summarization)

| Feature | How it uses CC |
|---------|---------------|
| `cc_backend.py` | Uses `claude -p` as LLM for all summarization |
| `cc_session_data.py` | Fetches CC session stats for activity reports |
| `summarize smart` | Cron-friendly daily summarization using CC |

The CC backend constructs structured prompts with JSON schemas (Chain-of-Key pattern) and calls `claude -p` for high-quality summarization output.

### gptme-whatsapp (messaging)

| Feature | How it uses CC |
|---------|---------------|
| `BACKEND=claude-code` | Full CC backend support for WhatsApp responses |
| `--resume` | CC conversation history per WhatsApp sender |
| `--append-system-prompt-file` | Identity/personality injection |
| CLAUDECODE stripping | Proper env cleanup for nested execution |

This is the most complete CC integration outside the core packages — handles conversation continuity, identity, and non-interactive execution.

### Plugins with CC Relevance

| Plugin | Integration |
|--------|-------------|
| **gptme-claude-code** | Bridge: spawns `claude -p` from gptme IPython. Functions: `analyze`, `ask`, `fix`, `implement` (with worktree), `check_session`, `kill_session`. Prompt cache protection (warns >240s, raises >=300s sync). |
| **gptme-gptodo** | Coordinator pattern: `delegate()` supports `backend="claude"`. Enables gptme agent to spawn CC subagents. |
| **gptme-ralph** | Iterative execution with plan files — supports `--backend claude` for CC-powered iteration. |

## Common Invocation Patterns

### Non-interactive prompt execution
```bash
claude -p "your prompt here" --model claude-opus-4-6
```

### With system prompt append
```bash
claude -p "prompt" --append-system-prompt "additional context"
```

### From Python (using ClaudeCodeExecutor)
```python
from gptme_runloops.utils.executor import get_executor
executor = get_executor("claude-code")
result = executor.execute(
    prompt="...",
    workspace=Path("/path/to/workspace"),
    timeout=3000,
    model="claude-opus-4-6",
)
```

### Spawning in tmux (via gptodo)
```bash
gptodo spawn my-task --backend claude --type explore --timeout 1800
```

## Known Limitations

1. **No tool restrictions for CC backend**: `ClaudeCodeExecutor` can't pass tool allowlists — CC's `claude -p` doesn't support `--tools`. TeamRun coordinator gets full capabilities.

2. **No tool format control**: CC ignores `--tool-format` flag. Tools are always in CC's native format.

3. **Output capture only**: `capture_output=True` means CC's interactive features (approval prompts, etc.) don't work. Prompts must be fully autonomous.

4. **Nesting requires env stripping**: Forgetting to strip `CLAUDECODE` will cause subprocess to fail silently or error.

5. **No streaming**: `subprocess.run` blocks until completion. No intermediate output during long runs.

6. **Session state isolation**: Each `claude -p` invocation starts fresh — no conversation history unless using `--resume` (gptme-whatsapp pattern).

## Workflow: CC Agent Team via gptodo

```
1. gptodo worktree create <task> --branch worktree-<name>
2. gptodo spawn <task> --backend claude --type explore
3. gptodo output <agent-id>          # monitor
4. gptme-sessions signals <trajectory>  # analyze after completion
5. gptme-sessions post-session --harness claude-code --trajectory <path>
6. gptodo worktree merge <task>       # merge results
```

## Workflow: Autonomous Loop with CC

```bash
# One-shot autonomous run
gptme-runloops autonomous --backend claude-code --workspace /path/to/workspace

# Scheduled via systemd timer (see dotfiles/scripts/runs/)
# Timer triggers → autonomous loop → CC executes → post-session records
```
