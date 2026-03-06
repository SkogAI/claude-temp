# gptmail

## Purpose

Email automation package for gptme agents. Provides a full CLI for reading, composing, replying, and sending emails, plus a background watcher daemon that automatically processes unreplied emails by spawning gptme subagents. Uses markdown files for email storage (version-controllable, human-readable) while supporting full MIME including HTML rendering. Includes shared communication utilities (OAuth, rate limiting, state tracking, monitoring) designed to be reusable across communication platforms.

## CLI Commands

| Command | Description |
|---|---|
| `gptmail compose <to> <subject> [content]` | Create a new email draft. Opens editor if content omitted. `--from` for custom sender. |
| `gptmail send <message_id>` | Send a draft email via SMTP |
| `gptmail list [folder]` | List messages in folder (default: inbox) |
| `gptmail read <message_id>` | Read a message. `--thread` for full thread, `--thread-only` for structure only |
| `gptmail reply <message_id> [content]` | Reply to a message with proper threading (References chain). `--from` for custom sender |
| `gptmail archive <message_id>` | Move message to archive |
| `gptmail thread <message_id>` | Show conversation thread. `--structure` for outline, `--stats` for statistics |
| `gptmail check-unreplied` | List unreplied emails from allowlisted senders. `--folders` to specify folders |
| `gptmail process-unreplied` | Process unreplied emails with gptme. `--dry-run` supported. `--folders` to specify |
| `gptmail mark-no-reply <message_id>` | Mark email as processed with no reply needed. `--reason` for explanation |
| `gptmail list-completed` | List completed emails (replied or no-reply). `--status` filter |
| `gptmail check-completion-status <id>` | Debug: check if a message ID is marked completed |
| `gptmail check-complexity` | Analyze complexity of unreplied emails. `--threshold` (0-1), `--mark-complex` to auto-skip |
| `gptmail sync-maildir [folder]` | Sync from maildir to markdown format. `all` for inbox+sent |
| `gptmail export-maildir <folder> <dest>` | Export markdown emails to maildir format |
| `gptmail import-maildir <source> <folder>` | Import maildir emails to markdown format |

Entry point: `gptmail = gptmail.cli:cli`

## Python API

### Core: `gptmail.lib.AgentEmail`

Main class handling all email operations.

| Method | Description |
|---|---|
| `AgentEmail(workspace_dir, agent_email=None)` | Initialize with workspace path |
| `compose(to, subject, content, from_address=None, reply_to=None, references=None)` | Create draft, returns message_id |
| `send(message_id)` | Send draft via SMTP |
| `list_messages(folder)` | List messages as `[(msg_id, subject, date)]` |
| `read_message(message_id, include_thread=False)` | Read message content |
| `get_thread_messages(message_id)` | Get all messages in a thread |
| `archive(message_id)` | Move to archive folder |
| `get_unreplied_emails(folders=None)` | Get unreplied from allowlisted senders: `[(msg_id, subject, sender)]` |
| `process_unreplied_emails(callback, folders=None)` | Process each unreplied email with callback |
| `sync_from_maildir(folder)` | Import from maildir to markdown |
| `export_to_maildir(folder, dest_path)` | Export to maildir format |
| `import_from_maildir(source_path, folder)` | Import from maildir to markdown |

### Complexity: `gptmail.complexity`

| Class | Description |
|---|---|
| `ComplexityScore` | Dataclass with `score` (0-1), `reasons`, `is_complex`, `summary` property |
| `ComplexityDetector` | Analyzes emails for length, questions, sensitive keywords, decision phrases, recipients. Threshold: 0.6 |

### Communication Utils: `gptmail.communication_utils`

Shared utilities designed for cross-platform reuse:

| Module | Key Classes | Description |
|---|---|---|
| `auth.oauth` | `OAuthConfig`, `OAuthManager` | OAuth 2.0 flows. Factory methods: `.for_twitter()`, `.for_github()` |
| `auth.tokens` | `TokenInfo` | Token storage dataclass |
| `rate_limiting.limiters` | `RateLimiter`, `GlobalRateLimiter` | Token bucket rate limiting. Factory: `.for_platform("email"|"twitter"|"discord")` |
| `state.tracking` | `ConversationTracker`, `MessageInfo`, `MessageState` | Thread-safe conversation/message state management with file locks |
| `state.locks` | `FileLock`, `file_lock` | File-based locking for concurrent access |
| `monitoring.loggers` | — | Logging utilities |
| `monitoring.metrics` | — | Metrics collection |
| `messaging.headers` | — | Message header utilities |
| `error_handling.errors` | — | Error types |
| `error_handling.retry` | — | Retry logic |

### Watcher: `gptmail.watcher`

Background daemon that runs sync cycles: mbsync (Gmail fetch) -> maildir sync -> process unreplied emails with gptme.

| Function | Description |
|---|---|
| `run_daemon()` | Continuous loop, 30s between cycles |
| `run_sync_cycle(email_limit=None)` | Single cycle: mbsync -> sync -> process |
| `process_unreplied_emails(limit=None)` | Process unreplied with file locking |

CLI: `python -m gptmail.watcher [once|one]`

## Setup Requirements

- **Gmail via IMAP/SMTP**: Requires mbsync configured with `gmail-INBOX` and `gmail-Sent` labels
- **Email workspace**: Directory structure under `<workspace>/email/` with `inbox/`, `sent/`, `drafts/`, `archive/` folders
- **gptme**: Required for `process-unreplied` and watcher (spawns gptme subagents)
- **Python >= 3.10**

## Configuration

| Env Var | Description |
|---|---|
| `AGENT_EMAIL` | Default sender email address |
| `EMAIL_ALLOWLIST` | Comma-separated allowed sender addresses |
| `EMAIL_WORKSPACE` | Path to email workspace directory |
| `EDITOR` | Preferred editor for composing (default: vim) |

Also loads `.env` file from git workspace root.

## Dependencies

- `click>=8.0` (CLI framework)
- `requests>=2.28` (HTTP for OAuth)
- `python-dateutil>=2.8` (date parsing)
- `markdown>=3.4` (HTML rendering)
- Build: `hatchling`

## Claude Code Integration

No direct `--backend claude` support. The watcher and `process-unreplied` spawn **gptme** subagents. Could be adapted to use Claude Code by modifying the subprocess command in `watcher.py:run_gptme_for_email()` or `cli.py:process_unreplied()`.

The `communication_utils` (OAuth, rate limiting, state tracking) are platform-agnostic and reusable from any Python context.

## Key Source Files

| File | Purpose |
|---|---|
| `src/gptmail/cli.py` | Click CLI with all commands (compose, send, read, reply, thread, check-unreplied, sync, complexity, etc.) |
| `src/gptmail/lib.py` | Core `AgentEmail` class — email storage, MIME handling, threading, maildir sync, SMTP sending (~800 lines) |
| `src/gptmail/watcher.py` | Background daemon — mbsync, maildir sync, gptme dispatch with file locking |
| `src/gptmail/complexity.py` | `ComplexityDetector` and `ComplexityScore` for email routing decisions |
| `src/gptmail/__init__.py` | Package metadata, version |
| `src/gptmail/__main__.py` | `python -m gptmail` entry |
| `src/gptmail/communication_utils/auth/oauth.py` | OAuth 2.0 manager with Twitter/GitHub factory methods |
| `src/gptmail/communication_utils/auth/tokens.py` | Token dataclass |
| `src/gptmail/communication_utils/rate_limiting/limiters.py` | Token bucket rate limiter with platform defaults |
| `src/gptmail/communication_utils/state/tracking.py` | `ConversationTracker` — thread-safe message state management |
| `src/gptmail/communication_utils/state/locks.py` | File-based locking |
| `src/gptmail/communication_utils/monitoring/loggers.py` | Logging utilities |
| `src/gptmail/communication_utils/monitoring/metrics.py` | Metrics collection |
| `src/gptmail/communication_utils/messaging/headers.py` | Message header utilities |
| `src/gptmail/communication_utils/error_handling/errors.py` | Error types |
| `src/gptmail/communication_utils/error_handling/retry.py` | Retry logic |
| `scripts/cleanup_duplicates.py` | Maintenance script for deduplication |
| `src/gptmail/migrate_lock_format.py` | Lock format migration |
| `tests/test_import.py` | Import tests |
| `tests/test_mime.py` | MIME handling tests |
