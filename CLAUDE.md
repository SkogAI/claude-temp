# ~/claude/CLAUDE.md

claude's home folder, working directory, and headquarters. everything here belongs to claude — change freely.

<skogai_todo>

for anything task-related — planning, creating, executing, reviewing, closing — use the `task-manager` agent. it handles the full lifecycle via `skogai-todo` and `gh`.

</skogai_todo>

<skogapi>

- skogapi: FastAPI service at localhost:9999 — wraps skogcli, skogparse, agents, config, scripts
- service: `systemctl --user restart skogai-skogapi` — start script at `~/.config/systemd/skogai-skogapi-start.sh`
- code: `projects/skogapi/main.py`
- systemd services follow pattern: `skogai-*.service` + `~/.config/systemd/skogai-*-start.sh`
- env needed in service: `SKOGAI_CONFIG_DIR=/skogai/config`, `PATH="$HOME/.local/bin:$PATH"`
- agents via `skogcli agent list/read/create`, NOT file directories
- `uvx` isolates env — always use full paths or export PATH in start scripts

</skogapi>

## Project Structure

- @.cass/ - CASS Memory playbook and blocked patterns (cm)
- @.claude-plugin/ - Plugin configuration (plugin.json, marketplace.json)
- @commands/ - Custom slash commands (plugin component)
- @docs/claude-code/ - Extensive Claude Code documentation
- @docs/skogix/ - User documentation (definitions.md, user.md)
- @skills/ - Custom skills for Claude Code (plugin component)
  - @skills/claude-code-modifications/SKILL.md - main project skill
  - @skills/claude-code-modifications/scripts/update-plugins.sh - plugin update/reload
- @lessons/ - Keyword-triggered behavioral lessons (gptme format, injected via hooks)
- @JOINK/ - Reference implementation of lesson system from gptme

## Tools

- NEVER use sed or awk -- use proper tools (yq, jq, etc.)
- `yq --front-matter=extract '<query>' file.md` -- parse YAML frontmatter from markdown
- when a tool version is wrong, ask skogix to install the correct one

## Lessons System

- @lessons/ contains keyword-triggered behavioral lessons (gptme format)
- lessons are NOT skills -- they are small contextual injections ("hey remember this")
- @JOINK/ has the reference implementation (python lesson system from gptme)
- don't touch lesson content, don't reorganize lessons -- build the injection mechanism

<!-- br-agent-instructions-v1 -->

---

## Beads Workflow Integration

This project uses [beads_rust](https://github.com/Dicklesworthstone/beads_rust) (`br`/`bd`) for issue tracking. Issues are stored in `.beads/` and tracked in git.

### Essential Commands

```bash
# View ready issues (unblocked, not deferred)
br ready              # or: bd ready

# List and search
br list --status=open # All open issues
br show <id>          # Full issue details with dependencies
br search "keyword"   # Full-text search

# Create and update
br create --title="..." --description="..." --type=task --priority=2
br update <id> --status=in_progress
br close <id> --reason="Completed"
br close <id1> <id2>  # Close multiple issues at once

# Sync with git
br sync --flush-only  # Export DB to JSONL
br sync --status      # Check sync status
```

### Workflow Pattern

1. **Start**: Run `br ready` to find actionable work
2. **Claim**: Use `br update <id> --status=in_progress`
3. **Work**: Implement the task
4. **Complete**: Use `br close <id>`
5. **Sync**: Always run `br sync --flush-only` at session end

### Key Concepts

- **Dependencies**: Issues can block other issues. `br ready` shows only unblocked work.
- **Priority**: P0=critical, P1=high, P2=medium, P3=low, P4=backlog (use numbers 0-4, not words)
- **Types**: task, bug, feature, epic, chore, docs, question
- **Blocking**: `br dep add <issue> <depends-on>` to add dependencies

### Session Protocol

**Before ending any session, run this checklist:**

```bash
git status              # Check what changed
git add <files>         # Stage code changes
br sync --flush-only    # Export beads changes to JSONL
git commit -m "..."     # Commit everything
git push                # Push to remote
```

### Best Practices

- Check `br ready` at session start to find available work
- Update status as you work (in_progress → closed)
- Create new issues with `br create` when you discover tasks
- Use descriptive titles and set appropriate priority/type
- Always sync before ending session

<!-- end-br-agent-instructions -->

<!-- skogai-br-patch-v1 -->

### Advanced Commands (not in base template)

```bash
# shortcuts
br q fix the login bug                # quick capture — prints ID only
br update <id> --claim                # atomic: assignee=you + in_progress
br close <id> --suggest-next          # close + show newly unblocked work

# filtering
br list --all                         # include closed
br list -s in_progress -p P0 -p P1    # combine status + priority filters
br list --long                        # detailed output
br blocked                            # blocked issues only

# dependencies
br dep rm <id> <depends-on>           # remove dependency
br dep tree <id>                      # visualize dependency tree

# scheduling
br defer <id> --until "2w"            # defer (relative or absolute date)
br undefer <id>                       # make ready again

# import (after git pull brings new .beads/ changes)
br sync --import-only                 # jsonl → db

# diagnostics
br stats                              # project overview
br doctor                             # read-only health check
```

### Agent Tips

- `--json` on any command for machine-readable output
- `--actor claude` to tag actions in audit trail
- `br q` over `br create` for fast capture during work
- `br close --suggest-next` to chain work without `br ready`
- `br` never executes git commands — you always commit manually

<!-- end-skogai-br-patch -->

---

## CASS Memory (cm)

Procedural memory system -- learned rules that persist across sessions. Config lives at `.cass/playbook.yaml` (project) and `~/.cass-memory/playbook.yaml` (global).

### Session Start (always do this)

```bash
cm context "<brief task description>" --json
```

Returns relevant rules, anti-patterns, and history snippets for the current task. Reference rule IDs when following them.

### During Work

- Leave inline feedback when rules help or hurt:
  - `// [cass: helpful <id>] - reason`
  - `// [cass: harmful <id>] - reason`

### Key Commands

```bash
cm context "<task>" --json    # get rules for a task (start of every session)
cm ls                         # list playbook rules
cm add "<rule>"               # add a rule manually
cm stats                      # playbook health metrics
cm doctor                     # system health check
cm reflect --days 7 --json    # extract rules from recent sessions
cm guard --install            # install safety guard hook
```

### Maintenance

- `cm reflect --days 7` periodically to learn from sessions
- `cm doctor --fix` to resolve health issues
- `cm starters` for built-in starter playbooks
