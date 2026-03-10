# workflow phases

<purpose>

Phase-by-phase guide for the git workflow skill. Each phase has preconditions, exact commands, and notes.

</purpose>

<content>

## Phase 1: Pick

Select a task or issue to work on.

**Option A — From GitHub issue:**
```bash
gptodo import --source github --repo <owner/repo> --state open
gptodo list --state new --priority high
gptodo edit <task-id> --set state active
```

**Option B — From existing task:**
```bash
gptodo list --state new
gptodo show <task-id>
gptodo edit <task-id> --set state active
```

**Option C — Ad-hoc (no task file):**
Just provide a description. Skip task tracking.

## Phase 2: Sync

Fetch upstream to ensure we branch from latest.

**Multi-repo (all repos):**
```bash
gita fetch
gita ll  # review status, check for dirty/behind
```

**Single repo:**
```bash
git fetch origin
git log --oneline origin/master..master  # check if local is behind
```

**Note:** If local master is behind, consider `git pull --ff-only` before branching.

## Phase 3: Branch

Create an isolated worktree for the work.

```bash
# Create worktree (preferred)
wt switch --create <branch-name>

# From specific base
wt switch --create <branch-name> --base origin/master

# If worktree already exists, just switch to it (idempotent)
wt switch <branch-name>

# With Claude agent launch
wt switch --create <branch-name> -x claude -- '<task description>'
```

**Branch naming:** Use descriptive kebab-case. Examples: `fix-auth-timeout`, `feat-user-dashboard`, `refactor-db-queries`.

**Worktree location:** `~/.claude/worktrees/<branch-name>/`

## Phase 4: Work

Code, test, commit loop. Stay in the worktree.

```bash
# Stage files individually (NEVER git add . or git add -A)
git add <file1> <file2>

# Commit with conventional format
git commit -m "{type}({phase}-{plan}): {description}"

# Types: feat, fix, test, refactor, docs, chore

# Check status
git status
wt list  # see all worktrees
```

**Rules:**
- One commit per logical change
- Stage files individually
- Include `Co-Authored-By:` line when working with Claude

## Phase 5: Ship

Push branch and create PR against master.

```bash
# Push branch (first time)
git push -u origin HEAD

# Create PR
gh pr create --base master --title "<title>" --body "<body>"

# Or draft PR
gh pr create --base master --draft --title "<title>"
```

**PR conventions:**
- Title: short, imperative (under 70 chars)
- Body: summary bullets + test plan
- Base: always `master`

## Phase 6: Merge

After PR is approved, or for trivial local changes.

**Option A — Local merge via wt (small/personal changes):**
```bash
wt merge
# Squashes, rebases onto master, fast-forward merges, removes worktree
# Then push:
git push
```

**Option B — GitHub PR merge:**
```bash
gh pr merge <number>
# Or merge via GitHub UI
```

**Note:** `wt merge` auto-removes worktree and branch. After GitHub merge, you still need cleanup (Phase 7).

## Phase 7: Cleanup

Remove worktree and mark task done.

**After `wt merge` (auto-cleaned):**
```bash
# Worktree already removed. Just mark task done:
gptodo edit <task-id> --set state done
# Push master:
git push
```

**After GitHub PR merge:**
```bash
# Remove worktree (branch already merged on remote)
wt remove <branch-name>
# Mark task done
gptodo edit <task-id> --set state done
```

**Verify:**
```bash
wt list          # should not show the old worktree
gptodo status    # task should be done
git log -1       # verify merge commit on master
```

</content>
