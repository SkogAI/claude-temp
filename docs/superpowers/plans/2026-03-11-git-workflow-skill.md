# Git Workflow Skill Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a unified git workflow skill that encapsulates the full development cycle (pick issue, sync, worktree, work, commit, push, PR, merge, cleanup) across multiple repos using gita, wt, gptodo, and gh.

**Architecture:** A SKILL.md file provides routing and workflow instructions. It delegates to three tools: `gita` for multi-repo sync, `wt` (worktrunk) for worktree lifecycle, and `gptodo` for task tracking. A companion command (`/work`) gives a conversational entry point that loads the skill and walks through the workflow phases.

**Tech Stack:** gita (Python, multi-repo), worktrunk/wt (Rust CLI, worktree management), gptodo (Python CLI, task management), gh (GitHub CLI, PRs/issues)

---

## Research Findings

### gita capabilities

gita manages multiple git repos from a single command. All repos live in `~/.local/src/` and are registered via `gita add`.

**Key commands for the workflow:**

| Command | Purpose |
|---------|---------|
| `gita ll` | Display status of all repos (branch, dirty, ahead/behind) |
| `gita ll <group>` | Status for a specific group |
| `gita fetch` | Fetch all repos (optional input = all repos) |
| `gita pull` | Pull all repos (optional input = all repos) |
| `gita fetch <repo>` | Fetch specific repo |
| `gita super <repo> <git-cmd>` | Run arbitrary git command on specific repo |
| `gita shell <repo> <cmd>` | Run shell command in repo directory |
| `gita ls <repo>` | Get absolute path of a repo |
| `gita group ll` | Show groups with their repos |
| `gita context <group>` | Set context so all commands scope to a group |
| `gita freeze` | Export repo state (URLs, paths, branches) for backup |

**Groups:** Repos can be organized into groups. The user has a `src` group with 17 repos. Context can be set to `auto` (based on cwd).

**Config location:** `$XDG_CONFIG_HOME/gita/repos.csv` (likely `~/.config/gita/repos.csv`). Custom commands in `~/.config/gita/cmds.json`.

**Relevant for workflow:** `gita fetch` before starting work ensures all repos are up-to-date. `gita ll` provides a quick overview of which repos have pending changes. `gita super <repo> <cmd>` can target specific repos for git operations.

### worktrunk (wt) capabilities

wt is a Rust CLI for git worktree management. Worktrees are addressed by branch name, paths are computed from a template.

**Key commands for the workflow:**

| Command | Purpose |
|---------|---------|
| `wt switch --create <branch>` | Create new branch + worktree, switch to it |
| `wt switch --create <branch> --base <ref>` | Create from specific base |
| `wt switch -x claude -c <branch> -- '<prompt>'` | Create worktree + launch Claude |
| `wt switch <branch>` | Switch to existing worktree |
| `wt switch -` | Switch to previous worktree |
| `wt switch ^` | Switch to default branch worktree |
| `wt switch pr:123` | Switch to a GitHub PR's branch |
| `wt list` | List worktrees with status (staged, ahead, behind) |
| `wt merge` | Squash, rebase onto target, fast-forward merge, cleanup |
| `wt merge <target>` | Merge into specific branch (default: default branch) |
| `wt merge --no-squash` | Preserve commit history |
| `wt merge --no-remove` | Keep worktree after merge |
| `wt merge -y` | Skip approval prompts |
| `wt remove` | Remove current worktree + delete branch if merged |
| `wt remove <branch>` | Remove specific worktree |
| `wt remove -D` | Force-delete unmerged branch |
| `wt step commit` | Commit staged changes (with LLM message generation) |
| `wt config show` | Show configuration |

**Merge pipeline:** squash -> rebase -> pre-merge hooks -> fast-forward merge -> pre-remove hooks -> cleanup -> post-merge hooks. Backup ref saved to `refs/wt-backup/<branch>`.

**Hooks (project `.config/wt.toml`):**
- `post-create` -- run after worktree creation (blocking, e.g. `npm install`)
- `post-start` -- run after creation (background, e.g. dev server)
- `post-switch` -- run after switching worktrees
- `pre-commit` -- run before committing
- `pre-merge` -- run before merging (e.g. tests)
- `post-merge` -- run after merge
- `pre-remove` -- run before removal

**Agent handoff pattern (tmux):**
```bash
tmux new-session -d -s <branch> "wt switch --create <branch> -x claude -- '<prompt>'"
```

**User's setup:** Worktrees land in `~/.claude/worktrees/`. Default branch is `master`. User merges via `wt merge` (local fast-forward into master) or PR workflow (`git push -u origin HEAD` + `gh pr create --base master`).

### gptodo capabilities

gptodo is a Python CLI for task management, GitHub issue sync, and agent spawning.

**Key commands for the workflow:**

| Command | Purpose |
|---------|---------|
| `gptodo list` | List tasks with filters |
| `gptodo list --priority high` | Filter by priority |
| `gptodo list --state active` | Filter by state |
| `gptodo show <task-id>` | Show task details |
| `gptodo edit <task-id> --set state active` | Update task state |
| `gptodo edit <task-id> --set state done` | Mark task done |
| `gptodo import --source github --repo <owner/repo>` | Import GitHub issues as tasks |
| `gptodo import --source github --repo <owner/repo> --state open` | Import open issues |
| `gptodo import --source github --repo <owner/repo> --label bug` | Import by label |
| `gptodo fetch --all` | Refresh external issue states |
| `gptodo sync --update --use-cache` | Sync task states |
| `gptodo status` | Overview of all tasks |
| `gptodo spawn <task-id> --backend claude` | Spawn sub-agent in tmux |
| `gptodo spawn <task-id> --backend claude --type explore` | Spawn with agent type |
| `gptodo worktree create <task-id>` | Create worktree for task |
| `gptodo worktree list` | List worktrees |
| `gptodo worktree status <path>` | Worktree status |
| `gptodo validate` | Validate task files |
| `gptodo check` | Check task completion |
| `gptodo lock acquire <task-id>` | Lock task for agent |
| `gptodo lock release <task-id>` | Release task lock |

**Task format:** YAML frontmatter in `tasks/*.md` with fields: `state` (new/active/paused/done/cancelled/someday), `priority` (low/medium/high), `task_type` (project/action), `assigned_to`, `tags`, `tracking` (GitHub URL).

**Environment:** `GPTODO_TASKS_DIR` env var points to tasks directory. User's is at `/home/skogix/claude/.skogai/tasks`.

**Known bug:** `gptodo import` writes unquoted YAML dates. Fix: `sed -i 's/^created: \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$/created: "\1"/' tasks/*.md`

**gptodo worktree module:** Uses raw `git worktree add` internally. Creates worktrees in `.worktrees/` relative to workspace. Has `create_pr_from_worktree()` which does `git push -u origin <branch>` + `gh pr create`. Has `merge_worktree()` for local merge. Has `cleanup_merged_worktrees()`.

### Existing skills/commands

**Skills directory (`/home/skogix/claude/skills/`):** Currently empty (no files). No `gita/` or `worktrunk/` skill directories exist in the user's workspace (they exist in the source repos at `~/.local/src/`).

**Commands directory (`/home/skogix/claude/commands/`):**
- `catchup.md` -- Context restoration after `/clear` (git history, uncommitted changes, TODOs)
- `wrapup.md` -- End-of-session checklist: ship (commit, push, worktree cleanup via `wt list`/`wt merge`), remember (memory updates), review (self-improvement), journal
- `learn.md` -- Learning/insight capture

**Relevant overlap:** The `wrapup.md` command already references `wt list`, `wt merge`, `wt remove`, `gptodo fetch --all`, `gptodo list`, and `gptodo edit`. The new skill should complement these rather than duplicate.

**Worktrunk skill exists at source:** `/home/skogix/.local/src/worktrunk/skills/worktrunk/SKILL.md` with 14 reference files. This is the upstream skill from the worktrunk project. It could be symlinked or @-referenced.

**gptme skill exists:** `/home/skogix/claude/skills/gptme/SKILL.md` with references covering gptodo, sessions, runloops.

---

## File Structure

```
skills/git-workflow/
  SKILL.md                    # Main skill file: routing, workflow phases, command reference
  reference/
    tool-commands.md          # Quick-reference table of all gita/wt/gptodo/gh commands
    workflow-phases.md        # Detailed phase descriptions with exact commands
    troubleshooting.md        # Common issues and recovery procedures

commands/
  work.md                     # Entry point command: /work [issue-url|task-id|description]
```

**Modifications to existing files:**
- `commands/wrapup.md` -- Add @-reference to skill for consistency (optional, low priority)

---

## Tasks

### Phase 1: Skill skeleton

- [ ] **Create `skills/git-workflow/SKILL.md`**
  - Path: `/home/skogix/claude/skills/git-workflow/SKILL.md`
  - Frontmatter: `name: git-workflow`, description covering "worktree", "workflow", "pr", "merge", "issue"
  - Sections: `<what_is_this>`, routing table to references, workflow phases overview
  - Workflow phases (high-level, delegates to reference/workflow-phases.md):
    1. **Pick** -- select task/issue (gptodo or gh)
    2. **Sync** -- fetch upstream (gita or git fetch)
    3. **Branch** -- create worktree (wt switch --create)
    4. **Work** -- commit loop (git add, git commit, following commit conventions)
    5. **Ship** -- push + PR (git push -u origin HEAD, gh pr create --base master)
    6. **Merge** -- after PR approval: wt merge or GitHub merge
    7. **Cleanup** -- remove worktree, mark task done

### Phase 2: Reference files

- [ ] **Create `skills/git-workflow/reference/tool-commands.md`**
  - Path: `/home/skogix/claude/skills/git-workflow/reference/tool-commands.md`
  - Tables of actual CLI commands with flags, grouped by tool
  - Include the exact commands found during research (above)
  - Note which commands are idempotent vs. destructive

- [ ] **Create `skills/git-workflow/reference/workflow-phases.md`**
  - Path: `/home/skogix/claude/skills/git-workflow/reference/workflow-phases.md`
  - Each phase with preconditions, exact commands, idempotency notes, error recovery
  - Phase details:

  **Phase 1 -- Pick:**
  ```bash
  # Option A: From GitHub issue
  gptodo import --source github --repo <owner/repo> --state open
  gptodo list --state new --priority high
  gptodo edit <task-id> --set state active

  # Option B: From existing task
  gptodo list --state new
  gptodo show <task-id>
  gptodo edit <task-id> --set state active

  # Option C: Ad-hoc (no task file)
  # Just provide a description, skip task tracking
  ```

  **Phase 2 -- Sync:**
  ```bash
  # Multi-repo sync (if working across repos)
  gita fetch
  gita ll  # Review status

  # Single-repo sync
  git fetch origin
  git log --oneline origin/master..master  # Check if behind
  ```

  **Phase 3 -- Branch:**
  ```bash
  # Create worktree with wt (preferred)
  wt switch --create <branch-name>
  # or with specific base
  wt switch --create <branch-name> --base origin/master

  # Idempotent: if worktree exists, wt switch just cd's to it
  wt switch <branch-name>

  # With agent launch
  wt switch --create <branch-name> -x claude -- '<task description>'
  ```

  **Phase 4 -- Work:**
  ```bash
  # Stage files individually (convention: never git add .)
  git add <file1> <file2>

  # Commit with conventional format
  git commit -m "feat(phase-plan): description"

  # Check status
  git status
  wt list  # See all worktrees
  ```

  **Phase 5 -- Ship:**
  ```bash
  # Push branch
  git push -u origin HEAD

  # Create PR
  gh pr create --base master --title "<title>" --body "<body>"

  # Or draft PR
  gh pr create --base master --draft --title "<title>"
  ```

  **Phase 6 -- Merge:**
  ```bash
  # Option A: Local merge via wt (for personal/small projects)
  wt merge
  # or with explicit target
  wt merge master

  # Option B: After GitHub PR merge, just cleanup
  # (PR merged on GitHub, branch already merged)
  ```

  **Phase 7 -- Cleanup:**
  ```bash
  # Remove worktree (after merge)
  wt remove
  # or specific branch
  wt remove <branch-name>

  # Mark task done
  gptodo edit <task-id> --set state done

  # Push master after local merge
  git push
  ```

- [ ] **Create `skills/git-workflow/reference/troubleshooting.md`**
  - Path: `/home/skogix/claude/skills/git-workflow/reference/troubleshooting.md`
  - Cover: merge conflicts during `wt merge`, stale worktrees, gptodo date bug workaround, `wt remove` with untracked files (`-f`), unmerged branch removal (`-D`)

### Phase 3: Command entry point

- [ ] **Create `commands/work.md`**
  - Path: `/home/skogix/claude/commands/work.md`
  - Frontmatter: name, description with trigger phrases ("start work", "pick an issue", "new feature", "work on")
  - Instructions: load skill, ask user which phase to start from, walk through phases
  - Accept argument: issue URL, task ID, or free-text description
  - Example invocations:
    ```
    /work https://github.com/owner/repo/issues/42
    /work my-task-id
    /work "Add user authentication"
    ```

### Phase 4: Symlinks and integration

- [ ] **Symlink skill into `.claude/skills/`** (if not auto-discovered)
  ```bash
  ln -sf ../../skills/git-workflow /home/skogix/claude/.claude/skills/git-workflow
  ```

- [ ] **Symlink command into `.claude/commands/`** (if not auto-discovered)
  ```bash
  ln -sf ../../commands/work.md /home/skogix/claude/.claude/commands/work.md
  ```

- [ ] **Verify skill loads correctly**
  - Test: invoke `/work` in a Claude Code session
  - Test: mention "worktree workflow" and verify skill activates

### Phase 5: Wrapup integration (optional)

- [ ] **Update `commands/wrapup.md`** to add @-reference to skill for consistency
  - Path: `/home/skogix/claude/commands/wrapup.md`
  - Purpose: ensure wrapup's "ship it" phase is consistent with the workflow skill

---

## Gaps and Unknowns

1. **gita config location unclear:** The user's `~/.config/gita/` directory does not exist at the expected path. May be at a different XDG location or not yet configured. The skill should handle the case where gita is not set up (fall back to single-repo git fetch).

2. **wt vs gptodo worktree overlap:** Both `wt` and `gptodo worktree` create worktrees. The user's MEMORY.md strongly favors `wt` for worktree management. The skill should use `wt` for worktree lifecycle and `gptodo` only for task state tracking. `gptodo worktree create` should NOT be used -- it uses raw git commands and puts worktrees in `.worktrees/`, not the configured wt path.

3. **PR workflow vs local merge:** The user's workflow routes through master (no develop branch). PRs target master. `wt merge` does local fast-forward into master. The skill should support both paths and let the user choose per-task.

4. **Multi-repo workflow complexity:** When a task spans multiple repos (e.g., changes to both gptme-contrib and claude), the skill needs to handle creating worktrees in multiple repos. This is an advanced case -- start with single-repo and add multi-repo as a follow-up.

5. **gptodo import date bug:** Still present (tracked: SkogAI/dot-skogai#6). The skill's troubleshooting reference should document the sed workaround.

6. **Upstream worktrunk skill:** The worktrunk project ships its own skill at `~/.local/src/worktrunk/skills/worktrunk/`. Consider symlinking or @-referencing it rather than duplicating wt documentation. The git-workflow skill should route to it for wt-specific deep dives.
