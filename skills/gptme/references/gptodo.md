# gptodo

## Purpose

Task management and work queue generation for gptme agent workspaces. Provides a full-featured CLI for managing tasks stored as markdown files with YAML frontmatter, generating prioritized work queues from local tasks and GitHub/Linear issues, multi-agent coordination via file-based locks and agent registry, sub-agent spawning (gptme or Claude Code backends), git worktree isolation, dependency graph visualization, auto-unblocking, and structured waiting conditions (PR CI, PR merged, comment pattern, time-based).

## CLI Commands

| Command | Description |
|---|---|
| `gptodo status` | Show status of tasks (supports `--compact`, `--all`, `--github`, `--repo`) |
| `gptodo list` | List tasks in table format (`--sort`, `--active-only`, `--context`, `--json`, `--jsonl`) |
| `gptodo show <id>` | Show detailed info about a task (by numeric ID or name) |
| `gptodo effective <id>` | Show effective state including blocking reasons |
| `gptodo check` | Validate task integrity and relationships (`--fix`, or pass specific files) |
| `gptodo edit <id>` | Edit task metadata (`--set state active`, `--set priority high`, `--add tag feature`) |
| `gptodo generate-queue` | Generate `state/queue-generated.md` from tasks + GitHub issues (`--workspace`, `--github-username`, `--user`) |
| `gptodo import` | Import issues from GitHub/Linear as task files (`--source github --repo owner/repo`) |
| `gptodo fetch` | Fetch/sync issue state for cached URLs |
| `gptodo sync` | Sync task state with external trackers (`--update --use-cache`) |
| `gptodo lock acquire <id>` | Acquire exclusive lock on a task |
| `gptodo lock release <id>` | Release lock on a task |
| `gptodo lock status <id>` | Check lock status |
| `gptodo lock list` | List all active locks |
| `gptodo lock cleanup` | Remove expired locks |
| `gptodo agents list` | List registered agents |
| `gptodo agents cleanup` | Remove stale agent registrations |
| `gptodo spawn` | Spawn sub-agent (`--backend gptme/claude/codex`, `--background`, `--model`, `--coordination`) |
| `gptodo sessions list` | List sub-agent sessions |
| `gptodo sessions check <id>` | Check session status |
| `gptodo sessions output <id>` | Get session output |
| `gptodo sessions kill <id>` | Kill running session |
| `gptodo sessions cleanup` | Remove old session files |
| `gptodo worktree create <task-id>` | Create git worktree for isolated work |
| `gptodo worktree list` | List worktrees |
| `gptodo worktree status <path>` | Get worktree status |
| `gptodo worktree pr <path>` | Create PR from worktree |
| `gptodo worktree merge <path>` | Merge worktree locally |
| `gptodo worktree remove <path>` | Remove worktree |
| `gptodo worktree cleanup` | Remove merged worktrees |
| `gptodo deptree <id>` | Show dependency tree (`--format ascii/mermaid`, `--direction up/down/both`) |
| `gptodo checker <id>` | Run checker verification on task |
| `gptodo checker poll <id>` | Poll task until completion |
| `gptodo waiting check` | Check and resolve structured waiting conditions |

## Python API

### Core Data Structures (`gptodo.utils`)

| Class/Function | Description |
|---|---|
| `TaskInfo` | Dataclass with name, state, priority, tags, requires, subtasks, issues, metadata, path |
| `SubtaskCount` | Named tuple (completed, total) |
| `DirectoryConfig` | Config for directory type (states, special_files, emoji) |
| `StateChecker` | Validates tasks against a DirectoryConfig |
| `load_tasks(tasks_dir)` | Load all tasks from directory as `list[TaskInfo]` |
| `compute_effective_state(task, all_tasks, issue_cache)` | Compute effective state considering dependencies |
| `is_task_ready(task, all_tasks, issue_cache)` | Check if task is unblocked |
| `normalize_state(state)` | Map deprecated states (new->backlog, someday->backlog, paused->backlog) |

### Business Logic (`gptodo.lib`)

| Function | Description |
|---|---|
| `fetch_github_issues(repo, state, labels, assignee, limit)` | Fetch issues via `gh` CLI |
| `fetch_linear_issues(team, state, limit)` | Fetch issues via Linear GraphQL API (needs `LINEAR_API_KEY`) |
| `generate_task_filename(title, number, source)` | Generate slug filename from issue |
| `generate_task_content(issue, source, priority)` | Generate task file with frontmatter |
| `map_priority_from_labels(labels)` | Map labels to priority string |
| `poll_github_notifications(since)` | Poll GitHub notifications API |

### Locking (`gptodo.locks`)

| Function | Description |
|---|---|
| `acquire_lock(task_id, worker, timeout_hours, force)` | Atomic lock acquisition with `fcntl.flock` |
| `release_lock(task_id, worker, force)` | Release lock |
| `get_lock(task_id)` | Get current lock |
| `list_locks()` | List all locks |
| `cleanup_expired_locks()` | Remove expired locks |
| `is_task_locked(task_id, exclude_worker)` | Check if locked |
| `TaskLock` | Dataclass: task_id, worker, started, timeout_hours |

### Agent Registry (`gptodo.agents`)

| Function | Description |
|---|---|
| `register_agent(agent_id, workspace, instance_type)` | Register agent via `state/agents/{id}.status` |
| `update_agent_status(agent_id, status, current_task)` | Update heartbeat and status |
| `unregister_agent(agent_id)` | Remove registration |
| `list_agents(include_stale, timeout_minutes)` | List active agents |
| `cleanup_stale_agents(timeout_minutes)` | Remove stale registrations (default: 30min timeout) |
| `AgentInfo` | Dataclass: agent_id, instance_type, started, last_heartbeat, current_task, status |

### Sub-Agent Spawning (`gptodo.subagent`)

| Function | Description |
|---|---|
| `spawn_agent(task_id, prompt, agent_type, backend, background, timeout, model, coordination)` | Spawn gptme/claude/codex sub-agent (foreground or tmux background) |
| `check_session(session_id)` | Check/update session status |
| `get_session_output(session_id)` | Get output (live tmux + saved file) |
| `kill_session(session_id)` | Kill running tmux session |
| `list_sessions(status)` | List all sessions |
| `cleanup_sessions(older_than_hours)` | Remove old sessions + kill orphaned tmux |
| `AgentSession` | Dataclass: session_id, task_id, agent_type, backend, status, tmux_session |

### Worktree Management (`gptodo.worktree`)

| Function | Description |
|---|---|
| `create_worktree(task_id, branch_name, base_branch)` | Create git worktree in `.worktrees/` |
| `list_worktrees()` | List all worktrees |
| `remove_worktree(path, force)` | Remove worktree |
| `create_pr_from_worktree(path, title, body, draft)` | Push + create PR via `gh` |
| `merge_worktree(path, target_branch)` | Local merge + cleanup |
| `get_worktree_status(path, base_branch)` | Get status (commits ahead, changes) |
| `cleanup_merged_worktrees(base_branch)` | Auto-remove merged worktrees |

### Dependency Visualization (`gptodo.deptree`)

| Function | Description |
|---|---|
| `build_dependency_graph(tasks)` | Build graph of `DependencyNode` objects |
| `detect_circular_dependencies(nodes)` | Find cycles via DFS |
| `get_dependency_tree(task_id, repo_root, format, direction)` | Get ASCII or Mermaid tree |

### Auto-Unblocking (`gptodo.unblock`)

| Function | Description |
|---|---|
| `auto_unblock_with_fan_in(completed_ids, all_tasks, tasks_dir)` | Main entry: unblock dependents + fan-in parent completion |
| `find_dependent_tasks(completed_id, all_tasks)` | Find tasks depending on completed task |
| `check_fan_in_completion(completed_task, all_tasks, tasks_dir)` | Check if all subtasks done -> mark parent done |

### Structured Waiting (`gptodo.waiting`)

| Class/Function | Description |
|---|---|
| `WaitType` | Enum: PR_CI, PR_MERGED, COMMENT, TIME, TASK |
| `WaitCondition` | Dataclass with type, ref, pattern, resolved |
| `parse_waiting_for(metadata)` | Parse frontmatter waiting_for field (string/dict/list) |
| `check_pr_ci(ref)` | Check if PR CI checks pass via `gh pr checks` |
| `check_pr_merged(ref)` | Check if PR merged via `gh pr view` |
| `check_comment(ref, pattern)` | Check for matching comment |
| `check_time(ref)` | Check if ISO timestamp has passed |

### Checker Pattern (`gptodo.checker`)

| Function | Description |
|---|---|
| `run_checker(task_id, repo_root, config)` | Verify task state (subtasks, deps, transitions) |
| `poll_task_completion(task_id, repo_root, config)` | Poll until done/failed/timeout |
| `VALID_TRANSITIONS` | State machine: backlog->todo->active->ready_for_review->done |
| `CheckerConfig` | Configurable: poll_interval, max_polls, verify flags |

## Configuration

| Env Var | CLI Flag | Description |
|---|---|---|
| `GPTODO_TASKS_DIR` | `--tasks-dir` | Path to tasks directory (overrides auto-detection) |
| `TASKS_REPO_ROOT` | `--workspace` | Agent workspace root path |
| `GITHUB_USERNAME` | `--github-username` | GitHub username for assignee filtering |
| `LINEAR_API_KEY` | - | Linear API key for issue fetching |

### Workspace Directory Conventions

```
workspace/
  tasks/           # Task files (*.md with YAML frontmatter)
  tasks/archive/   # Archived tasks
  state/
    queue-generated.md    # Work queue output
    queue-generated-{user}.md  # Per-user work queue
    locks/         # Task lock files (*.lock JSON)
    agents/        # Agent status files (*.status JSON)
    sessions/      # Sub-agent session files (*.json, *.output, *.prompt)
  journal/         # Session journal entries
  .worktrees/      # Git worktrees for isolated work
```

### Task File Format

```yaml
---
state: active        # backlog, todo, active, ready_for_review, waiting, done, cancelled
priority: high       # low, medium, high, urgent
task_type: project   # project (multi-step) or action (single-step)
assigned_to: agent   # agent name
tags: [ai, dev]
requires: [other-task-name]  # task-based dependencies
tracking: ["https://github.com/owner/repo/issues/123"]
waiting_for:         # structured waiting (string, dict, or list)
  type: pr_ci
  ref: "owner/repo#123"
spawned_from: parent-task  # fan-in parent reference
spawned_tasks: [sub1, sub2]  # fan-in children
---
```

## Dependencies

- **Runtime**: click, rich, tabulate, python-frontmatter
- **External CLIs**: `gh` (GitHub CLI), `tmux` (background sessions)
- **Optional**: LINEAR_API_KEY for Linear integration
- **Depended on by**: gptme-runloops (autonomous run uses `gptodo generate-queue`), agent workspace scripts

## Claude Code Integration

### Sub-Agent Spawning with `--backend claude`

`spawn_agent(backend="claude")` invokes `claude -p --dangerously-skip-permissions --tools default`. Key behaviors:

1. **CLAUDECODE env stripping**: Both foreground and background modes unset `CLAUDECODE` and `CLAUDE_CODE_ENTRYPOINT` to allow nesting (running Claude Code from within a Claude Code session).

2. **API key clearing**: When `backend="claude"` (or `"codex"`), API keys (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `OPENROUTER_API_KEY`) are explicitly unset. This forces Claude Code to use OAuth subscription (flat-fee) rather than metered API keys.

3. **Background sessions**: Uses tmux with `bash -l` login shell. Prompt written to temp file to avoid tmux command-length limits. Output captured to file with `tail -f` for tmux pane visibility.

4. **Coordination support**: `--coordination` flag auto-generates agent ID, announces on coordination bus, prepends agent ID to prompt, and passes `COORDINATION_DB` env var.

5. **System prompt file**: `--append-system-prompt-file` passed to `claude` CLI for coordination or custom system prompts.

### Limitations

- `clear_keys` defaults to `True` for claude/codex backends — no API key forwarding
- Timeout enforced via `timeout` command wrapper in tmux

## Key Source Files

| File | Purpose |
|---|---|
| `src/gptodo/cli.py` | Click CLI: all commands, status display, Rich output formatting (~1000 lines) |
| `src/gptodo/lib.py` | Business logic: GitHub/Linear API, task content generation, notifications |
| `src/gptodo/utils.py` | Data classes (TaskInfo, DirectoryConfig), constants, task loading, cache mgmt |
| `src/gptodo/generate_queue.py` | QueueGenerator: work queue from tasks + GitHub issues, dependency filtering, unblocking power |
| `src/gptodo/locks.py` | File-based task locking with `fcntl.flock` for atomic operations |
| `src/gptodo/agents.py` | Agent registry: file-based status tracking, heartbeat, stale cleanup |
| `src/gptodo/subagent.py` | Sub-agent spawning: gptme/claude/codex backends, tmux, coordination |
| `src/gptodo/worktree.py` | Git worktree lifecycle: create, PR, merge, cleanup |
| `src/gptodo/deptree.py` | Dependency graph: build, cycle detection, ASCII/Mermaid rendering |
| `src/gptodo/checker.py` | Task verification: subtask completion, dep resolution, state validity |
| `src/gptodo/unblock.py` | Auto-unblock: clear waiting_for, fan-in parent completion |
| `src/gptodo/waiting.py` | Structured waiting: PR CI/merge, comment pattern, time-based conditions |
| `src/gptodo/__init__.py` | Package metadata, version |
| `src/gptodo/__main__.py` | Entry point for `python -m gptodo` |
