---
name: gita
description: Multi-repo git management with the gita CLI. Use when checking status across multiple repositories, fetching/pulling all repos at once, running git commands across repo groups, or when the user mentions gita, repo groups, or wants a bird's-eye view of their git repositories. Also use when working with repos in ~/claude/ or ~/.local/src/ and you need to understand what's there or operate on them in bulk.
---

# Gita — Multi-Repo Git Manager

Gita manages multiple git repos from any working directory. Two core capabilities:

1. **Dashboard** — see status of all repos (or a group) side by side
2. **Delegation** — run git commands against specific repos without cd-ing

## Groups

Groups are the primary way to scope operations. The user's current setup:

| Group | What | Repos |
|-------|------|-------|
| `skogai` | Everything | All repos below combined (~19) |
| `claude-home` | `~/claude/` workspace | claude, skogai-marketplace, worktrunk, claude-memory, gptme-contrib |
| `src` | `~/.local/src/` | aichat, argc, argc-completions, cli, docs, dot-skogai, episodic-memory, everything-claude-code, get-shit-done, gita, nelson, skogterm, src/claude-memory, src/gptme-contrib |
| `web` | skogai-web sites | skogai-intro, supabase, sassy-skogai-tales + blog repos |

Note: `src/claude-memory` and `src/gptme-contrib` are the `~/.local/src/` copies — auto-prefixed by gita to avoid collision with `~/claude/projects/` copies.

## Commands

### Status and overview

```bash
gita ll                    # all repos
gita ll claude-home        # just claude workspace
gita ll skogai             # everything
gita st                    # short status (all)
gita st claude-home        # short status (group)
```

The `ll` output shows: repo name, branch, dirty state indicators, last commit message, commit age, path, and tracking branch.

Dirty state indicators:
- `*` — unstaged changes
- `+` — staged changes
- `$` — stashed changes
- `?` — untracked files
- `↑` — ahead of remote
- `↓` — behind remote

### Running git commands on specific repos

```bash
gita super <repo> <git-command>     # run git command on one repo
gita super claude-memory pull       # pull a specific repo
gita super docs push                # push a specific repo
gita super nelson log --oneline -5  # recent commits for nelson
```

### Bulk operations

```bash
gita fetch                   # fetch all repos
gita fetch claude-home       # fetch just claude workspace
gita pull skogai             # pull all skogai repos
gita push src                # push all src repos
```

### Running shell commands

```bash
gita shell <repo> <shell-command>   # run arbitrary shell command in repo dir
gita shell docs "ls -la"            # list files in docs repo
```

### Context (default group)

```bash
gita context claude-home     # set default — all commands scope to this group
gita context none            # clear context
```

When context is set, `gita ll` shows only that group's repos.

### Repo management

```bash
gita ls                      # list all repo names
gita ls <repo>               # show repo path
gita add /path/to/repo       # register a repo
gita rm <repo>               # unregister a repo
gita group ls                # list all groups
gita group add -n <name> <repo1> <repo2> ...   # create group
gita group rm <name>         # remove group
gita rename <old> <new>      # rename a repo
```

### Other useful commands

```bash
gita br                      # show branches for all repos
gita br claude-home          # branches for a group
gita freeze                  # print all repo info (for backup/restore)
gita clone --from <freeze-output>  # restore repos from freeze
```

## Common Workflows

**Morning check** — see what's dirty or behind:
```bash
gita fetch skogai && gita ll skogai
```

**Before starting work** — pull everything:
```bash
gita pull claude-home
```

**Find uncommitted work** — look for `*`, `+`, or `?` indicators:
```bash
gita ll skogai
```

**Add a new project repo:**
```bash
gita add /path/to/new/repo
gita group add -n <group> <existing-repos...> <new-repo>
```

Note: group names cannot collide with repo names (e.g., can't name a group `claude` if there's a repo called `claude`).

## Config

Config lives at `~/.config/gita/`:
- `repos.csv` — registered repos (path, name, flags)
- `groups.csv` — group definitions
- `info.csv` — display column config
- `web.context` — current context setting
