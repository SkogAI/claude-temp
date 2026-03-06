# gptme-contrib-lib

## Purpose

Shared library providing the core framework for gptme agent input sources. Defines abstract base classes for task ingestion from external sources (GitHub issues, email, webhooks, scheduled triggers), Pydantic-based configuration management, token-bucket rate limiting, and monitoring/metrics/health-check infrastructure. This is the foundation layer that other packages build on when they need to poll external systems and create tasks.

## CLI Commands

| Command | Entry Point | Description |
|---------|-------------|-------------|
| (orchestrator CLI) | `orchestrator.py:main` (click) | `--config <path>` `--once` — poll all configured input sources, create tasks. No registered `[project.scripts]` entry — must be run as module. |

## Python API

### config.py — Configuration Management

| Symbol | Type | Description |
|--------|------|-------------|
| `get_workspace_path()` | function | Returns `GPTME_WORKSPACE` env or `~/workspace` |
| `get_agent_workspace()` | function | Smart workspace detection: env var > parent git repo (submodule-aware) > git root > cwd |
| `get_agent_config_dir()` | function | Returns `GPTME_CONFIG_DIR` env or `~/.config/gptme-agent` |
| `get_agent_data_dir()` | function | Returns `GPTME_DATA_DIR` env or `~/.local/share/gptme-agent` |
| `get_default_repo()` | function | Returns `GPTME_AGENT_REPO` env or `"owner/agent"` |
| `get_maildir_path()` | function | Returns `MAILDIR_PATH` env or `~/.local/share/mail/agent` |
| `RateLimitConfig` | Pydantic model | `max_requests_per_minute`, `max_requests_per_hour`, `enabled` |
| `GitHubSourceConfig` | Pydantic model | `repo`, `label`, `workspace_path`, `poll_interval_seconds`, `priority_labels`, `exclude_labels`, `rate_limit` |
| `EmailSourceConfig` | Pydantic model | `maildir_path`, `allowlist_file`, `workspace_path`, `poll_interval_seconds`, `rate_limit` |
| `WebhookSourceConfig` | Pydantic model | `queue_dir`, `workspace_path`, `poll_interval_seconds`, `auth_token`, `rate_limit` |
| `SchedulerSourceConfig` | Pydantic model | `schedule_file`, `state_file`, `workspace_path`, `check_interval_seconds`, `rate_limit` |
| `MonitoringConfig` | Pydantic model | `metrics_dir`, `health_check_interval_seconds`, `max_consecutive_failures`, `log_level` |
| `InputSourcesConfig` | Pydantic model | Top-level config combining all source configs. Methods: `from_dict()`, `from_yaml()`, `from_toml()`, `to_dict()`, `to_yaml()` |

### input_sources.py — Base Framework

| Symbol | Type | Description |
|--------|------|-------------|
| `InputSourceType` | Enum | `GITHUB`, `EMAIL`, `WEBHOOK`, `SCHEDULER` |
| `ValidationStatus` | Enum | `VALID`, `INVALID`, `SPAM`, `DUPLICATE` |
| `TaskRequest` | dataclass | Core task request: `source_type`, `source_id`, `title`, `description`, `created_at`, `author`, `priority`, `tags`, `metadata` |
| `ValidationResult` | dataclass | `status`, `message`, `details`, `.is_valid` property |
| `TaskCreationResult` | dataclass | `success`, `task_path`, `task_id`, `error` |
| `InputSource` | ABC | Abstract base class. Methods: `poll_for_inputs()`, `validate_input()`, `create_task()`, `acknowledge_input()`, `process_request()` |
| `InputSourceManager` | class | Manages multiple sources: `register_source()`, `poll_all_sources()`, `process_all_sources()` |

### input_source_impl.py — Concrete Implementations

| Symbol | Type | Description |
|--------|------|-------------|
| `GitHubInputSource` | class | Polls GitHub issues via `gh` CLI, creates task markdown files, comments on issues after task creation |
| `EmailInputSource` | class | Polls maildir `new/` directory, filters by allowlist, creates tasks, moves to `cur/` |
| `WebhookInputSource` | class | Polls JSON files in queue directory, creates tasks, deletes processed files |
| `SchedulerInputSource` | class | Reads YAML schedule config, supports `once`/`recurring` (daily/weekly/monthly) patterns, persists state |

### orchestrator.py — Coordination

| Symbol | Type | Description |
|--------|------|-------------|
| `InputSourceOrchestrator` | class | Initializes all enabled sources, manages poll intervals, `run_once()`, `run_continuous()` |

### monitoring.py — Metrics & Health

| Symbol | Type | Description |
|--------|------|-------------|
| `SourceMetrics` | dataclass | Per-source metrics: poll counts, task counts, error tracking, performance. Properties: `success_rate`, `is_healthy` |
| `MetricsCollector` | class | Persists metrics as JSON files. `get_or_create_metrics()`, `save_metrics()`, `generate_summary()` |
| `HealthChecker` | class | Health checks based on consecutive failure threshold |

### rate_limiter.py — Rate Limiting

| Symbol | Type | Description |
|--------|------|-------------|
| `RateLimitState` | dataclass | Token bucket state: `refill()`, `consume()`, `get_wait_time()` |
| `RateLimiter` | class | Dual bucket (per-minute + per-hour): `check_limit()`, `consume()`, `get_wait_time()`, `get_status()` |
| `MultiSourceRateLimiter` | class | Per-source rate limiters with different limits |

## Configuration

| Env Var | Default | Used By |
|---------|---------|---------|
| `GPTME_WORKSPACE` | `~/workspace` | All source configs |
| `GPTME_CONFIG_DIR` | `~/.config/gptme-agent` | Scheduler schedule file |
| `GPTME_DATA_DIR` | `~/.local/share/gptme-agent` | Scheduler state, metrics |
| `GPTME_AGENT_REPO` | `owner/agent` | GitHub source |
| `MAILDIR_PATH` | `~/.local/share/mail/agent` | Email source |

Config file: YAML loaded via `InputSourcesConfig.from_yaml()`. Sections: `github`, `email`, `webhook`, `scheduler`, `monitoring`.

## Dependencies

**Depends on:** click, pydantic, pyyaml, tomli (py<3.11)

**Depended on by:** Other packages that need workspace path detection (`get_agent_workspace()`) or config infrastructure. No other gptme-contrib packages currently import from it directly — it's designed as a standalone foundation.

## Claude Code Integration

- `get_agent_workspace()` is useful for detecting the workspace root when running inside submodules
- The input source framework could be used to auto-create tasks from GitHub issues in a claude-code workflow
- Config system provides standardized path resolution for agent workspaces

## Key Source Files

| File | Purpose |
|------|---------|
| `src/gptme_contrib_lib/config.py` | Pydantic config models, env var resolution, YAML/TOML loading |
| `src/gptme_contrib_lib/input_sources.py` | Abstract base classes: InputSource, TaskRequest, InputSourceManager |
| `src/gptme_contrib_lib/input_source_impl.py` | Concrete implementations: GitHub, Email, Webhook, Scheduler |
| `src/gptme_contrib_lib/orchestrator.py` | Poll coordination, continuous/once modes, click CLI |
| `src/gptme_contrib_lib/monitoring.py` | SourceMetrics, MetricsCollector, HealthChecker |
| `src/gptme_contrib_lib/rate_limiter.py` | Token bucket rate limiting (per-minute + per-hour) |

## Legacy: packages/lib/

The `packages/lib/` directory is an exact copy of the same package (identical `pyproject.toml`). It contains the same source structure under `src/gptme_contrib_lib/`. The modern `packages/gptme-contrib-lib/` is the canonical location — `lib/` is the legacy path kept for backwards compatibility.
