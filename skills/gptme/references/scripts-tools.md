# Scripts, Tools & Dotfiles

**Source:** `projects/gptme-contrib/`

## Scripts

All scripts live under `scripts/`. Most Python scripts use `uv run` with inline dependency metadata (PEP 723 script format).

### runs/ (Runloop Launchers)

Scripts for launching gptme agent sessions on a schedule.

| Script | Platform | Purpose |
|--------|----------|---------|
| `autonomous/autonomous-loop.sh` | Linux (systemd) | Continuously run autonomous sessions via systemd service. Derives service name from `AGENT_NAME` env var or `gptme.toml`. Supports `-n` for run count limit. |
| `launchd/autonomous-run.sh` | macOS (launchd) | Run single autonomous session using `run_loops` CLI. Accepts `--workspace` arg or `WORKSPACE` env var. |
| `launchd/project-monitoring.sh` | macOS (launchd) | Run project monitoring (GitHub notifications, PR updates). |
| `launchd/setup-launchd.sh` | macOS | One-command setup: copies plists to `~/Library/LaunchAgents/`, replaces paths, creates log dirs. |
| `launchd/*.plist` | macOS | launchd plist templates. Autonomous: hourly 6am-8pm. Monitoring: every 5 minutes. |

### status/ (Workspace Status)

Infrastructure status monitoring for gptme agents.

| Script | Purpose |
|--------|---------|
| `status.sh` | Main status script. Shows systemd services, locks, recent activity. Uses `AGENT_NAME` env var. |
| `util/status-systemd.sh` | Systemd service status (active/failed/next run). Supports `--no-color`. |
| `util/lock-status.sh` | Active locks and recent lock history. |

### context/ (System Prompt Generation)

Generic context generation for agent system prompts. Used via `gptme.toml`'s `context_cmd`.

| Script | Purpose |
|--------|---------|
| `context.sh` | Main orchestrator - calls all component scripts |
| `context-journal.sh` | Journal entries (supports flat + subdirectory formats) |
| `context-workspace.sh` | Workspace tree structure |
| `context-git.sh` | Git status + recent commits (with truncation to prevent prompt blowup) |
| `build-system-prompt.sh` | Reads `gptme.toml` and builds full system prompt including identity files |
| `find-agent-root.sh` | Locate agent workspace root directory |

**Design:** No agent-specific logic. Graceful degradation for missing directories. Safe to call via symlink from anywhere in a git repo.

### github/ (GitHub Integration)

| Script | Purpose |
|--------|---------|
| `context-gh.sh` | Generate GitHub context for agent prompts: notifications, open issues, CI status, open PRs. Reduces need for manual `gh` tool calls. |
| `repo-status.sh` | Check CI status across multiple repos. Color-coded output. Pass repos as `owner/repo:Label` args. |
| `activity-gate.sh` | Gate autonomous activity based on GitHub activity. |
| `check-notifications.sh` | Check GitHub notifications. |

### linear/ (Linear Integration)

Full Linear Agent Framework integration. Agents become @mentionable and assignable in Linear.

| File | Purpose |
|------|---------|
| `linear-webhook-server.py` | Flask webhook server (port 8081). Receives Linear AgentSessionEvents, validates tokens (auto-refresh), creates git worktrees, spawns gptme sessions. |
| `linear-activity.py` | CLI: emit activities back to Linear. Commands: `thought`, `response`, `error`, `token-status`, `refresh`, `auth`. |
| `setup.sh` | Interactive setup: prerequisites check, config prompts, symlinks, systemd services, OAuth flow. |
| `services/` | Systemd service templates for webhook server and ngrok. |

**Architecture:** Linear webhook -> ngrok tunnel -> Flask server -> gptme session in worktree -> merge back.

### communication/ (Social Platform Bots)

#### bluesky/
| File | Purpose |
|------|---------|
| `bluesky.py` | CLI for Bluesky social network. Posting, reading, interaction management. Uses AT Protocol (`atproto`). Requires app password in `.env`. |

#### discord/
| File | Purpose |
|------|---------|
| `discord_bot.py` | Full Discord bot powered by gptme. Per-channel conversations, rate limiting, model selection. Commands: `!help`, `!about`, `!clear`, `!status`, `!model`. Admin: `!backup`, `!shutdown`. |
| `rate_limiting.py` | Rate limiting utilities. |
| `test_discord_state.py` | State tracking tests. |

#### telegram/
| File | Purpose |
|------|---------|
| `telegram_bot.py` | Telegram bot using `python-telegram-bot`. Per-user rate limiting, trusted user allowlist. Commands: `/start`, `/clear`, `/help`. Shares `ConversationTracker` state with Discord bot. |

#### twitter/
| File | Purpose |
|------|---------|
| `twitter.py` | Twitter client: post tweets/threads, read timeline/lists, monitor mentions. |
| `workflow.py` | Tweet lifecycle: monitor -> draft -> review -> post. Supports auto mode. |
| `llm.py` | LLM-powered tweet evaluation, response generation, quality control. |
| `check_replies.py` | Check and process replies. |
| `trusted_users.py` | Trusted user management. |
| `config/config.yml` | Topics, evaluation criteria, response templates, rate limits. |

**Draft pipeline:** `tweets/new/` -> `tweets/review/` -> `tweets/approved/` -> `tweets/posted/` (or `tweets/rejected/`).

### communication_utils/ (Shared Infrastructure)

Cross-platform communication utilities library. Used by Discord, Telegram, Twitter bots.

| Module | Purpose |
|--------|---------|
| `rate_limiting/` | Token bucket algorithm, platform-specific presets (`RateLimiter.for_platform("twitter")`) |
| `messaging/` | Universal message IDs, conversation threading (`MessageHeaders`) |
| `auth/` | OAuth flows, token management (`TokenManager`, `OAuthManager`) |
| `state/` | File locks, conversation tracking (`FileLock`, `ConversationTracker`, `MessageState`) |
| `monitoring/` | Structured logging, metrics collection (`get_logger`, `MetricsCollector`) |
| `error_handling/` | Retry decorators with exponential backoff (`@retry`, `@retry_with_rate_limit`) |

**Status:** Phase 1 (shared utilities) complete. Phase 2 (platform refactoring) and Phase 3 (cross-platform features) not started.

### precommit/ (Validation Scripts)

Pre-commit hooks for repository quality.

| Script | Purpose |
|--------|---------|
| `check-names.sh` | Template validation - ensures template stays clean of instance names, forks replace patterns properly. |
| `validate_lesson_metadata.py` | Validates lesson YAML frontmatter has `match.keywords`. |
| `validate_task_frontmatter.py` | Validates YAML frontmatter in task/tweet files (required fields). |
| `check_markdown_links.py` | Verifies relative links in markdown files exist. |
| `validate_submodule_commits.py` | Ensures submodule commits exist upstream (prevents CI failures from unpushed local commits). |

### workspace_validator/ (Workspace Compliance)

| File | Purpose |
|------|---------|
| `validate.py` | Validates gptme agent workspace structure. Checks: required files (`gptme.toml`, `ABOUT.md`, `README.md`), required dirs (`journal/`, `knowledge/`, `lessons/`, `tasks/`), config parsing, fork script. |

**Usage:** CLI (`--workspace`, `--check`, `--quiet`), Python module (`validate_workspace(Path)`), GitHub Actions.

### Standalone Scripts

| Script | Purpose |
|--------|---------|
| `exa.py` | CLI for Exa search API. Web search with rich output. Deps: `exa-py`, `click`, `rich`. |
| `perplexity.py` | CLI for Perplexity AI search. Uses OpenAI-compatible API. Deps: `httpx`, `openai`, `click`. |
| `search.py` | Multi-source workspace search (tasks, knowledge, lessons + optional Roam, GitHub). |
| `tasks.py` | **DEPRECATED.** Wrapper for gptodo CLI. Install `gptodo` package directly instead. |
| `state-status.py` | Git status-like view of state directories (tasks/, tweets/). Reports missing links, summary stats. |
| `wordcount.py` | Word/line/character counter for files or stdin. Simple utility. |

## Tools

Standalone tools under `tools/`. These are more self-contained than scripts.

| Tool | Purpose |
|------|---------|
| `google_drive.py` | Google Drive integration: search, read docs, list recent, list folders. Requires OAuth2 credentials (`--setup`). Deps: `google-api-python-client`, `google-auth-oauthlib`. |
| `rss_reader.py` | RSS feed reader. Reads and displays feeds in compact format. Supports caching, concurrent fetching. Deps: `feedparser`, `beautifulsoup4`, `requests`. |
| `tool_pushover.py` | gptme ToolSpec for Pushover push notifications. Sends notifications via Pushover API. Requires `PUSHOVER_USER_KEY` and `PUSHOVER_API_TOKEN` env vars. |
| `gptodo/` | Tool variant of gptodo. Contains `docs/DESIGN-multi-agent-coordination.md` design doc. |

## Dotfiles

Agent configuration files providing global git hooks for safer development workflows.

**Installation:** `cd dotfiles && ./install.sh` (includes safety check for agent environments via `GPTME_AGENT` env var, `gptme.toml` with `[agent]` section, or autonomous service detection).

### Git Hooks

Installed globally via `core.hooksPath = ~/.config/git/hooks`. Apply to ALL repositories.

| Hook | Purpose |
|------|---------|
| `pre-commit` | **Master commit protection:** blocks direct commits to master/main in external repos. **Branch base validation:** warns if branch isn't based on latest origin/master. **Pre-commit integration:** auto-stages files modified by formatters. |
| `pre-push` | **Master push protection:** blocks direct pushes to master/main in external repos. **Worktree tracking:** validates upstream tracking before push. |
| `post-checkout` | **Branch base warning:** shows warning when checking out branch not based on origin/master. |

### Configuration

| File | Purpose |
|------|---------|
| `.config/git/allowed-repos.conf` | Repos where direct master/main commits and pushes are permitted. Sourced by pre-commit and pre-push hooks. |
| `.config/git/hooks/validate-branch-base.sh` | Branch base checking utility. |
| `.config/git/hooks/validate-worktree-tracking.sh` | Worktree tracking validation utility. |
| `install.sh` | Installation script: safety check, backup existing hooks, create symlinks, set `core.hooksPath`. |
