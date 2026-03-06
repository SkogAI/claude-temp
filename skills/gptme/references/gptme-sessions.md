# gptme-sessions

## Purpose

Session tracking and analytics for gptme agents. Provides an append-only JSONL-based session record system that any agent can use to track operational metadata across sessions: which harness ran, what model was used, what type of work was done, and the outcome. Includes trajectory signal extraction (gptme, Claude Code, Codex CLI, Copilot CLI formats), graded reward computation, Thompson sampling bandit optimization, session discovery across harnesses, and a post-session recording pipeline.

## CLI Commands

| Command | Description |
|---|---|
| `gptme-sessions` | Show stats (default when invoked without subcommand) |
| `gptme-sessions stats` | Show summary statistics (filter: `--model`, `--run-type`, `--harness`, `--outcome`, `--since`, `--json`) |
| `gptme-sessions query` | Query session records with filters (`--stats` for summary, `--json` for machine output) |
| `gptme-sessions runs` | Run analytics: duration distribution, NOOP rate, daily counts, model x outcome (`--since 14d`) |
| `gptme-sessions append` | Append a session record manually (`--harness`, `--model`, `--outcome`, `--duration`) |
| `gptme-sessions discover` | Discover trajectory files across harnesses (`--harness gptme/claude-code/codex/copilot`, `--since`, `--signals`) |
| `gptme-sessions signals <path>` | Extract productivity signals from a trajectory `.jsonl` file (`--json`, `--grade`, `--usage`) |
| `gptme-sessions post-session` | Full post-session pipeline: extract signals, determine outcome, append record (`--trajectory`, `--exit-code`, `--start-commit`, `--end-commit`) |

### Thompson Sampling Bandit CLI (via `python -m gptme_sessions.thompson_sampling`)

| Command | Description |
|---|---|
| `bandit status` | Show bandit status report |
| `bandit dashboard` | Unified dashboard across state files |
| `bandit sample` | Sample effectiveness scores for arms (`--arms`, `--seed`, `--context`) |
| `bandit update` | Update after session (`--outcome productive/noop/failed/float`, `--arms`, `--context`, `--decay-rate`) |
| `bandit decay` | Apply exponential decay to all arms (`--rate 0.99`) |
| `bandit prune` | Remove stale arms (`--min-selections`, `--max-age-days`) |

## Python API

### SessionRecord (`gptme_sessions.record`)

| Field | Type | Description |
|---|---|---|
| `session_id` | str | Auto-generated UUID[:8] |
| `timestamp` | str | ISO 8601 |
| `harness` | str | claude-code, gptme, codex, copilot |
| `model` | str | Raw model string (e.g. `claude-opus-4-6`) |
| `model_normalized` | property | Canonical short form (e.g. `opus`) |
| `run_type` | str | autonomous, monitoring, email, manual |
| `trigger` | str | timer, dispatch, manual, spawn |
| `category` | str | code, infrastructure, content, triage, knowledge, coordination |
| `recommended_category` | str | Category from Thompson sampling (intended) |
| `outcome` | str | productive, noop, failed |
| `duration_seconds` | int | Wall-clock duration |
| `token_count` | int | Total tokens (from trajectory) |
| `deliverables` | list[str] | Commit SHAs, PR URLs |
| `journal_path` | str | Path to journal entry |

Key methods: `to_dict()`, `from_dict(data)`, `to_json()`, `normalize_model(raw)`.

### SessionStore (`gptme_sessions.store`)

| Method | Description |
|---|---|
| `__init__(sessions_dir, sessions_file)` | Default: `./state/sessions/session-records.jsonl` |
| `append(record)` | Append one record to JSONL |
| `load_all()` | Load all records |
| `rewrite(records)` | Atomically rewrite entire store |
| `query(model, run_type, category, harness, outcome, since_days)` | Filter records |
| `stats(records)` | Compute summary: success_rate, by_model, by_run_type, by_harness, cross-tabs, duration |

Standalone functions: `compute_run_analytics(records)`, `format_stats(stats)`, `format_run_analytics(analytics)`.

### Signal Extraction (`gptme_sessions.signals`)

| Function | Description |
|---|---|
| `extract_from_path(jsonl_path)` | Auto-detect format + extract signals + grade + category in one call |
| `detect_format(msgs)` | Detect: gptme, claude_code, codex, copilot |
| `extract_signals(msgs)` | gptme format: tool calls, errors, commits, file writes, retries, duration |
| `extract_signals_cc(msgs)` | Claude Code format: tool_use/tool_result parsing |
| `extract_signals_codex(msgs)` | Codex CLI format: function_call/function_call_output |
| `extract_signals_copilot(msgs)` | Copilot CLI format: assistant.message/tool.execution_complete |
| `extract_usage_cc(msgs)` | Token usage from CC trajectories (input, output, cache_read, cache_creation) |
| `extract_usage_gptme(msgs)` | Token usage from gptme msg.metadata |
| `extract_usage_codex(msgs)` | Rate limit percentages from Codex |
| `extract_usage_copilot(msgs)` | Model info only |
| `grade_signals(signals)` | Compute 0.0-1.0 reward: commits strongest, writes secondary, error/retry penalties |
| `is_productive(signals)` | Binary: has commits or >=2 unique file writes |
| `infer_category(signals)` | Infer from commit prefixes, scopes, file paths. Requires >=2 votes. |

### Session Discovery (`gptme_sessions.discovery`)

| Function | Description |
|---|---|
| `discover_gptme_sessions(start, end)` | Scan `~/.local/share/gptme/logs/` (or `GPTME_LOGS_DIR`) by date prefix |
| `discover_cc_sessions(start, end)` | Scan `~/.claude/projects/` by first-line timestamp |
| `discover_codex_sessions(start, end)` | Scan `~/.codex/sessions/YYYY/MM/DD/` by directory structure |
| `discover_copilot_sessions(start, end)` | Scan `~/.copilot/session-state/` by first-line timestamp |
| `parse_gptme_config(session_dir)` | Parse `config.toml` for model, workspace, interactive |
| `decode_cc_project_path(encoded)` | Decode CC project dir name to filesystem path (lossy for hyphenated paths) |

### Post-Session Pipeline (`gptme_sessions.post_session`)

| Function | Description |
|---|---|
| `post_session(store, harness, model, exit_code, trajectory_path, ...)` | Full pipeline: extract signals, determine outcome, append record |
| `PostSessionResult` | Dataclass: record, grade, signals, token_count |

Outcome determination priority:
1. `exit_code not in (0, 124)` -> failed
2. Trajectory `is_productive()` -> productive/noop
3. Git HEAD comparison (`start_commit != end_commit`) -> productive/noop
4. `exit_code == 124` (timeout) -> noop
5. Default -> productive

### Thompson Sampling (`gptme_sessions.thompson_sampling`)

| Class | Description |
|---|---|
| `Bandit(state_dir)` | Manager: load/save state, sample, update, decay, prune |
| `BanditState` | Arms dict + contextual arms + session count |
| `BanditArm` | Beta-Bernoulli: alpha, beta, mean, variance, ucb, sample(), update(reward) |

Key features:
- **Contextual arms**: Learn per (category, model) context with hierarchical fallback
- **Exponential decay**: `alpha = 1 + gamma * (alpha - 1)` handles non-stationarity
- **Graded rewards**: Float [0,1] from `grade_signals()`, not just binary
- **Pruning**: Remove arms by min_selections or max_age_days

| Function | Description |
|---|---|
| `load_bandit_means(state_dir, arm_ids, context)` | Read-only convenience for integrating posteriors into scoring |
| `dashboard(state_files)` | Unified ASCII dashboard across multiple bandit state files |

## Configuration

| Env Var | Description |
|---|---|
| `GPTME_LOGS_DIR` | Override gptme session log directory |
| `CLAUDE_HOME` | Override Claude Code home (for projects dir) |
| `CODEX_SESSIONS_DIR` | Override Codex sessions directory |
| `COPILOT_STATE_DIR` | Override Copilot session-state directory |

### Storage

- **Session records**: `./state/sessions/session-records.jsonl` (append-only JSONL)
- **Bandit state**: `state/bandit/bandit-state.json`, `state/lesson-thompson/`, `state/thompson-control/`

## Dependencies

- **Runtime**: click (>=8.0), tomli (Python <3.11 only)
- **Optional**: gptme (for trajectory format), gh CLI (for commit file extraction in `infer_category`)
- **No dependency on**: gptodo, gptme-runloops (standalone package)
- **Depended on by**: gptme-runloops (uses `post_session` in run loop post-processing), agent workspace scripts

## Claude Code Integration

### Trajectory Signal Extraction

`extract_signals_cc(msgs)` parses Claude Code `.jsonl` trajectories:
- **Assistant turns**: `type='assistant'` with `message.content[]` containing `tool_use` items
- **Tool results**: `type='user'` with `message.content[]` containing `tool_result` items
- **Write tools**: Write, Edit, NotebookEdit (tracked via `input.file_path` or `input.notebook_path`)
- **Error detection**: `tool_result` items with `is_error=True`
- **Git commits**: Only from Bash tool output (tracks `tool_use_id` -> tool name mapping to avoid false positives from Read/Glob)

### Token Usage from CC Trajectories

`extract_usage_cc(msgs)` sums per-turn `message.usage` from Anthropic API:
- `input_tokens`, `output_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`
- Returns total tokens + last-seen model string
- This is the canonical way to get per-session token counts (not systemd journal parsing)

### Session Discovery

`discover_cc_sessions(start, end)` scans `~/.claude/projects/*/` for `.jsonl` files, using quick first-line timestamp extraction for date filtering. Project directory names are encoded paths (e.g. `-home-skogix-claude` -> `/home/skogix/claude`).

### Model Normalization

All Claude models are normalized: `claude-opus-4-6` -> `opus`, `anthropic/claude-sonnet-4-5` -> `sonnet`, `openrouter/anthropic/claude-haiku-4-5` -> `haiku`. This enables consistent grouping in stats regardless of provider prefix.

## Key Source Files

| File | Purpose |
|---|---|
| `src/gptme_sessions/cli.py` | Click CLI: stats, query, runs, append, discover, signals, post-session commands |
| `src/gptme_sessions/record.py` | SessionRecord dataclass, MODEL_ALIASES dict, normalize_model() |
| `src/gptme_sessions/store.py` | SessionStore: JSONL persistence, query, stats, run analytics |
| `src/gptme_sessions/signals.py` | Signal extraction for 4 formats (gptme, CC, Codex, Copilot), grading, category inference |
| `src/gptme_sessions/discovery.py` | Session file discovery across harnesses by date range |
| `src/gptme_sessions/post_session.py` | Post-session pipeline: signals -> outcome -> record |
| `src/gptme_sessions/thompson_sampling.py` | Beta-Bernoulli bandit: BanditArm, BanditState, Bandit manager, contextual arms, CLI |
| `src/gptme_sessions/__init__.py` | Public API exports (all key classes and functions) |
