# gptme-activity-summary

## Purpose

Activity summarization tool for gptme agents. Generates daily, weekly, and monthly summaries from journal entries, GitHub activity, gptme sessions, Claude Code sessions, ActivityWatch time tracking, and workspace activity (tweets, emails). Uses Claude Code as the LLM backend for high-quality summarization. Supports two modes: "agent" (journal-based, for AI agents) and "human" (ActivityWatch + GitHub, for human developers). Implements Chain-of-Key (CoK) pattern with structured JSON schemas.

## CLI Commands

Entry point: `summarize` (installed via `[project.scripts]`)

| Command | Options | Description |
|---------|---------|-------------|
| `summarize daily` | `--date DATE` `--mode agent\|human` `--github-user USER` `--raw` | Generate daily summary. DATE: YYYY-MM-DD, "today", "yesterday" (default) |
| `summarize weekly` | `--week WEEK` `--mode agent\|human` `--github-user USER` `--raw` | Generate weekly summary. WEEK: YYYY-Www, "current", "last" (default) |
| `summarize monthly` | `--month MONTH` `--mode agent\|human` `--github-user USER` `--raw` | Generate monthly summary. MONTH: YYYY-MM, "current", "last" (default) |
| `summarize smart` | `--date DATE` | Smart mode: always daily, auto weekly on Mondays, auto monthly on 1st |
| `summarize backfill` | `--from DATE --to DATE --force` | Backfill daily summaries for a date range |
| `summarize stats` | | Show journal entry statistics |

Global options: `-v/--verbose`, `--dry-run`

## Python API

### schemas.py — Data Models (Chain-of-Key pattern)

| Symbol | Type | Description |
|--------|------|-------------|
| `BlockerStatus` | Enum | `ACTIVE`, `RESOLVED`, `ESCALATED`, `DEFERRED` |
| `Decision` | dataclass | `topic`, `decision`, `rationale`, `session_id` |
| `Blocker` | dataclass | `issue`, `status`, `resolution`, `escalated_to` |
| `ModelUsage` | dataclass | `model`, `harness`, `sessions`, `tokens`, `cost` |
| `Interaction` | dataclass | `type`, `person`, `summary`, `url` |
| `ExternalContribution` | dataclass | `repo`, `title`, `pr_number`, `status`, `url` |
| `ExternalSignal` | dataclass | `source`, `title`, `relevance`, `url` |
| `Metrics` | dataclass | `sessions`, `commits`, `prs_merged`, `issues_closed`, `model_breakdown`, `total_tokens`, `total_cost` |
| `DailySummary` | dataclass | Full daily summary with `to_markdown()`. Target: <500 tokens rendered. |
| `WeeklySummary` | dataclass | Aggregates daily summaries with `to_markdown()`. Target: <1000 tokens. |
| `MonthlySummary` | dataclass | Aggregates weekly summaries with `to_markdown()`. Target: <2000 tokens. |

### cli.py — Core Generation Functions

| Function | Description |
|----------|-------------|
| `generate_daily_with_cc(date, verbose)` | Generate DailySummary using Claude Code backend |
| `generate_weekly_summary_cc(week, verbose)` | Generate WeeklySummary from daily summaries |
| `generate_monthly_summary_cc(month, verbose)` | Generate MonthlySummary from weekly summaries |

### Data Source Modules

| Module | Key Functions | Description |
|--------|---------------|-------------|
| `github_data.py` | `fetch_activity()`, `fetch_user_activity()`, `format_activity_for_prompt()` | GitHub commits, PRs, issues via `gh` CLI. `GitHubActivity` dataclass. |
| `session_data.py` | `fetch_session_stats()`, `fetch_session_stats_range()`, `format_sessions_for_prompt()`, `merge_session_stats()` | gptme session stats from log files. `SessionStats` dataclass. |
| `cc_session_data.py` | `fetch_cc_session_stats_range()` | Claude Code session stats |
| `cc_backend.py` | `summarize_daily_with_cc()`, `summarize_weekly_with_cc()`, `summarize_monthly_with_cc()`, `summarize_human_day_with_cc()`, `summarize_github_activity_with_cc()` | Claude Code LLM backend for summarization |
| `aw_data.py` | `fetch_aw_activity()`, `format_aw_activity_for_prompt()` | ActivityWatch time tracking data (apps, domains, active hours) |
| `workspace_data.py` | `fetch_workspace_activity()`, `format_workspace_activity_for_prompt()` | Workspace artifacts: posted tweets, sent emails |
| `generator.py` | `get_journal_entries_for_date()`, `save_summary()`, `JOURNAL_DIR`, `SUMMARIES_DIR`, `WORKSPACE` | Journal file scanning, summary file I/O |

## Configuration

| Env Var / Path | Description |
|----------------|-------------|
| `WORKSPACE` (from generator.py) | Workspace root for journal and summaries |
| `JOURNAL_DIR` | Journal entries directory |
| `SUMMARIES_DIR` | Output directory for summaries (daily/, weekly/, monthly/ subdirs) |
| ActivityWatch server | Must be running for AW data (graceful fallback if unavailable) |
| `gh` CLI | Must be authenticated for GitHub data |

Summaries are saved as both `.md` and `.json` files. JSON is preferred for loading, with markdown fallback.

## Dependencies

**Depends on:** gptme, gptme-sessions, click, aw-client

**Depended on by:** None directly. Used as a standalone CLI tool.

## Claude Code Integration

- The `summarize smart` command is designed for daily cron jobs — could be triggered by a Claude Code hook or scheduled task
- Summary output files (JSON/markdown) could feed into Claude Code session context
- The "human" mode with ActivityWatch integration works independently of gptme journal entries
- `cc_backend.py` directly uses Claude Code as the LLM for summarization

## Key Source Files

| File | Purpose |
|------|---------|
| `src/gptme_activity_summary/cli.py` | Click CLI with daily/weekly/monthly/smart/backfill/stats commands |
| `src/gptme_activity_summary/schemas.py` | Pydantic-like dataclass schemas: DailySummary, WeeklySummary, MonthlySummary + to_markdown() |
| `src/gptme_activity_summary/generator.py` | Journal scanning, summary file I/O, workspace path constants |
| `src/gptme_activity_summary/cc_backend.py` | Claude Code LLM backend for all summarization |
| `src/gptme_activity_summary/github_data.py` | GitHub activity fetching via gh CLI |
| `src/gptme_activity_summary/session_data.py` | gptme session stats from log files |
| `src/gptme_activity_summary/cc_session_data.py` | Claude Code session stats |
| `src/gptme_activity_summary/aw_data.py` | ActivityWatch time tracking integration |
| `src/gptme_activity_summary/workspace_data.py` | Workspace artifact scanning (tweets, emails) |
| `tests/` | Tests for aw_data, cc_backend, cc_session_data, github_data, session_data, workspace_data |
