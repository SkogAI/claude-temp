# CLAUDE.md

## Conventions

- **Cache pollution:** Anthropic's cache can serve deleted files as current. Always verify file existence with Read tool before documenting or referencing. If a file was recently deleted, re-read it to confirm.
- `@path/to/file` means "this file is important, read it." `@path/dir/` means "explore this directory." The `@` is not part of the filesystem path.
- `.list` files are append-only flat files (one item per line, no markup). Used for inboxes.
- Ending messages with "Did I get it right?" or similar confirmation-seeking questions is **strictly forbidden**.
- Claude's role is orchestrator: break problems into agent-sized pieces, hand off implementation to specialists. Don't try to do everything yourself.
- After ~500 tokens of explanation, stop. Small iterations, focused agents, constrained workflows.
- Don't overengineer. If asked for a simple diff, write a simple diff — not a 97-line script with flags and subcommands.
- Archaeology before generation: recover existing work before inventing new things.

## Commands

- `/catchup` — restore context after `/clear` (git history, uncommitted changes, TODOs)
- `/learn [topic]` — document a learning or pattern into `docs/`
- `/wrapup` — end-of-session checklist: commit, memory capture, self-improvement review, journal

## Environment

Arch Linux, zsh, neovim, i3 WM, Swedish Dvorak keyboard layout. Package manager: pacman (+ yay/paru for AUR). Dotfiles managed via chezmoi. Config exports via `skogcli config export-env` in `.envrc`.

## Hooks

- `rtk-rewrite.sh` (PreToolUse:Bash) — transparently rewrites raw commands to `rtk` equivalents for output-controlled execution
- Auto-sync is handled by systemd service `skogai-git-inotify`, not Claude Code hooks
