# gptme-runloops

## Purpose

Python-based run loop framework for autonomous AI agent operation. Provides a base class (`BaseRunLoop`) with lock management, git operations, structured logging, and consecutive-failure backoff, plus four concrete run loop implementations: autonomous task execution, project monitoring (GitHub PRs/issues/CI), email processing (Gmail via mbsync), and team coordination (coordinator-only pattern). Supports pluggable execution backends (gptme, Claude Code) via an executor abstraction.

## CLI Commands

| Command | Description |
|---|---|
| `gptme-runloops autonomous` | Run autonomous operation loop (`--workspace`, `--model`, `--tool-format`, `--backend`) |
| `gptme-runloops email` | Run email processing loop (`--workspace`, `--model`, `--tool-format`, `--backend`) |
| `gptme-runloops team` | Run team coordination loop (`--workspace`, `--tools`, `--model`, `--tool-format`, `--backend`) |
| `gptme-runloops monitoring` | Run project monitoring loop (`--workspace`, `--org`, `--repo`, `--author`, `--agent-name`, `--model`, `--backend`) |

Note: `run-loops` is a deprecated alias for `gptme-runloops` (both entry points exist in pyproject.toml).

### Shared Options

| Option | Description |
|---|---|
| `--backend` | Execution backend: `gptme` (default) or `claude-code` |
| `--workspace` | Workspace directory (default: cwd) |
| `--model` | Model override (e.g. `openrouter/moonshotai/kimi-k2.5@moonshotai`) |
| `--tool-format` | Tool format: `markdown`, `xml`, or `tool` |

## Python API

### BaseRunLoop (`gptme_runloops.base`)

Abstract base class for all run loops. Provides the lifecycle:

```
has_work() -> setup() -> pre_run() -> generate_prompt() -> execute() -> post_run() -> cleanup()
```

| Method | Description |
|---|---|
| `__init__(workspace, run_type, timeout, lock_wait, model, tool_format, executor)` | Configure loop |
| `has_work()` | Check for actionable work BEFORE acquiring lock (override in subclass) |
| `setup()` | Acquire lock, log start |
| `pre_run()` | Default: `git pull` with retry |
| `generate_prompt()` | Abstract: must return prompt string |
| `execute(prompt)` | Run configured executor |
| `post_run(result)` | Override for cleanup |
| `cleanup()` | Release lock, log duration |
| `run()` | Main orchestrator: returns exit code |

#### Backoff Infrastructure (opt-in)

| Method | Description |
|---|---|
| `_check_backoff(work_hash)` | Check if run should be skipped due to consecutive failures |
| `_record_backoff_success()` | Reset backoff counter (work resolved) |
| `_record_backoff_failure(work_hash)` | Increment failure counter |

Backoff schedule: 3 failures -> skip 1/2, 5 failures -> skip 3/4, 8 failures -> skip 7/8. State persisted in `state/{run_type}-backoff.json`.

### AutonomousRun (`gptme_runloops.autonomous`)

| Property | Value |
|---|---|
| `run_type` | `"autonomous"` |
| `timeout` | 3000s (50 min) |
| `lock_wait` | False |

Generates prompt from `scripts/runs/autonomous/autonomous-prompt.txt` template if exists, otherwise generates a 3-step workflow: loose ends check, CASCADE task selection, execution.

### ProjectMonitoringRun (`gptme_runloops.project_monitoring`)

| Property | Value |
|---|---|
| `run_type` | `"project-monitoring"` |
| `timeout` | 1800s (30 min) |
| `lock_wait` | False |

Features:
- **Repository discovery**: From GitHub orgs (`gh repo list`) + explicit repos
- **PR update tracking**: State files per PR, skip self-comments, detect bot mentions
- **CI failure detection**: Track new failures vs known ones
- **Assigned issue tracking**: Detect newly assigned issues
- **GitHub notification processing**: Filter by reason (mention, assign, review_requested, review, comment)
- **Linear notification retry**: Check for failed Linear webhook notifications
- **Comment spam prevention**: `CommentLoopDetector` + should_post_comment logic (5 rules)
- **Bot review detection**: `has_unresolved_bot_reviews()` skips bot reviews that can't be resolved via API
- **Work item caching**: `has_work()` caches work items for `generate_prompt()` reuse

State files stored in `logs/.project-monitoring-state/`.

### EmailRun (`gptme_runloops.email`)

| Property | Value |
|---|---|
| `run_type` | `"email"` |
| `timeout` | 1200s (20 min) |
| `lock_wait` | False |

Workflow:
1. `has_work()`: Sync emails via `mbsync -a` + `gptmail sync-maildir`, check unreplied via `gptmail check-unreplied`
2. Uses backoff: if same unreplied email set persists after execution, progressively skips runs
3. `post_run()`: Re-checks unreplied count and records success/failure for backoff

### TeamRun (`gptme_runloops.team`)

| Property | Value |
|---|---|
| `run_type` | `"team"` |
| `timeout` | 3000s (50 min) |
| `lock_wait` | False |
| `tools` | `gptodo,ipython,save,append,read,todoread,todowrite,complete` |

Implements coordinator-only pattern: top-level agent has restricted tools and must delegate all work to subagents via gptodo. Four phases: assess work, delegate, monitor & synthesize, complete.

### Executor Abstraction (`gptme_runloops.utils.executor`)

| Class | Description |
|---|---|
| `Executor` | Abstract base: `execute()`, `is_available()`, `name` |
| `GptmeExecutor` | Default: wraps `execute_gptme()` |
| `ClaudeCodeExecutor` | Invokes `claude -p` with CLAUDECODE env stripping |
| `get_executor(name)` | Factory: returns executor by name |
| `list_backends()` | Returns `['claude-code', 'gptme']` |

### ExecutionResult (`gptme_runloops.utils.execution`)

| Field | Description |
|---|---|
| `exit_code` | Process exit code |
| `timed_out` | True if timeout (exit_code=124) |
| `success` | True if exit_code==0 |

### Utility Modules

| Module | Key Functions |
|---|---|
| `utils.git` | `git_pull_with_retry(workspace, max_retries, retry_delay)` |
| `utils.github` | `is_bot_user(username)`, `has_unresolved_bot_reviews(repo, pr)`, `CommentLoopDetector` |
| `utils.lock` | `RunLoopLock(lock_dir, lock_name)`: fcntl-based lock with history log for calendar |
| `utils.logging` | `get_logger(name)`, `log_execution_start()`, `log_execution_end()` |
| `utils.prompt` | `get_agent_name(workspace)` from `gptme.toml`, `generate_base_prompt()` |
| `utils.execution` | `execute_gptme()`: find gptme binary, build command, tee to log, handle timeout |

## Configuration

| Env Var | Description |
|---|---|
| `GITHUB_AUTHOR` | GitHub username for monitoring (default for `--author`) |
| `AGENT_NAME` | Agent name for prompts (default for `--agent-name`) |
| `GPTME_SHELL_TIMEOUT` | Shell command timeout (set by execute_gptme) |
| `GPTME_CHAT_HISTORY` | Enable chat history (set to "true" by execute_gptme) |

### Workspace Conventions

```
workspace/
  gptme.toml           # Agent config (agent.name)
  scripts/runs/
    autonomous/autonomous-prompt.txt  # Custom autonomous prompt template
    team/team-prompt.txt              # Custom team prompt template
  logs/
    gptme-{type}.lock                 # Run loop lock files
    .project-monitoring-state/        # PR/CI/notification state files
  state/
    {type}-backoff.json               # Backoff state per run type
  ~/.cache/gptme/logs/                # Global log files (not in workspace)
```

### Systemd Timer Integration

Run loops are designed to be triggered by systemd timers (every 5 minutes typically). The `has_work()` pattern ensures:
- No lock acquired if no work found
- No calendar entry created for check-only runs
- Backoff prevents token waste on unresolvable work

## Dependencies

- **Runtime**: click (>=8.0), pyyaml (>=6.0), tomli (Python <3.11)
- **External CLIs**: `gptme` (for GptmeExecutor), `claude` (for ClaudeCodeExecutor), `gh` (for monitoring), `mbsync` (for email)
- **Optional**: gptmail package (for email loop), Linear API scripts
- **Depends on**: None at Python level (standalone), but functionally integrates with gptodo (autonomous/team prompts reference gptodo commands)

## Claude Code Integration

### ClaudeCodeExecutor

The `ClaudeCodeExecutor` class invokes `claude -p <prompt>` as a subprocess:

1. **CLAUDECODE env stripping**: Removes `CLAUDECODE` and `CLAUDE_CODE_ENTRYPOINT` from environment to allow nesting — running `claude` from within a Claude Code session would otherwise fail because Claude Code detects it's already running.

2. **Invocation**: `claude -p <prompt>` with optional `--model` and `--append-system-prompt` flags. Uses `capture_output=True` + `stdin=subprocess.DEVNULL`.

3. **Timeout handling**: `subprocess.TimeoutExpired` -> `ExecutionResult(exit_code=124, timed_out=True)`.

4. **Limitations**:
   - **No tool restriction**: Claude Code CLI doesn't support `--tools` flag, so `TeamRun` coordinator tool restrictions are NOT enforced when using `--backend claude-code`. A warning is logged.
   - **No tool format**: `--tool-format` is ignored (not supported by CC CLI).
   - **No streaming**: Output is captured and printed after completion, not streamed in real-time like gptme.

### Using `--backend claude-code`

```bash
# Run autonomous loop with Claude Code
gptme-runloops autonomous --workspace /path/to/workspace --backend claude-code

# Project monitoring with Claude Code + specific model
gptme-runloops monitoring --backend claude-code --model claude-opus-4-6 --org myorg
```

### Integration with gptodo spawn

The `gptodo spawn --backend claude` command (from the gptodo package) is a separate but complementary integration. While `gptme-runloops --backend claude-code` runs the entire run loop via Claude Code, `gptodo spawn` creates individual sub-agent sessions. The TeamRun coordinator can use gptodo to spawn Claude Code sub-agents while itself running on either backend.

## Key Source Files

| File | Purpose |
|---|---|
| `src/gptme_runloops/cli.py` | Click CLI: autonomous, email, team, monitoring commands with shared --backend option |
| `src/gptme_runloops/base.py` | BaseRunLoop ABC: lifecycle, lock, git, backoff infrastructure |
| `src/gptme_runloops/autonomous.py` | AutonomousRun: 3-step workflow (loose ends, selection, execution) |
| `src/gptme_runloops/project_monitoring.py` | ProjectMonitoringRun: repo discovery, PR/CI/issue/notification tracking, spam prevention |
| `src/gptme_runloops/team.py` | TeamRun: coordinator-only pattern with restricted tools |
| `src/gptme_runloops/email.py` | EmailRun: mbsync + gptmail integration with backoff |
| `src/gptme_runloops/utils/executor.py` | Executor ABC, GptmeExecutor, ClaudeCodeExecutor, backend registry |
| `src/gptme_runloops/utils/execution.py` | ExecutionResult, execute_gptme() with tee logging |
| `src/gptme_runloops/utils/git.py` | git_pull_with_retry() |
| `src/gptme_runloops/utils/github.py` | Bot detection, comment loop prevention, review analysis |
| `src/gptme_runloops/utils/lock.py` | RunLoopLock: fcntl-based with calendar history |
| `src/gptme_runloops/utils/logging.py` | Structured logging setup |
| `src/gptme_runloops/utils/prompt.py` | Agent name from gptme.toml, base prompt generation |
