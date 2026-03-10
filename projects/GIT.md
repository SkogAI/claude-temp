# git workflow: worktree → develop → PR → master

## goal

1. an issue is chosen
2. a worktree is created
3. we do work in the worktree
4. `wt merge` into develop
5. develop accumulates changes from multiple worktrees
6. PR from develop against master

## tools

| tool | role |
|------|------|
| `claude --worktree <name> --tmux=classic` | create worktree + tmux + start claude |
| `wt` (worktrunk) | worktree lifecycle: list, merge, remove |
| `gita` | multi-repo overview (`gita ll`) |
| `gh` | PRs against master from develop |

## setup

- `wt config state default-branch set develop` — so `wt merge` targets develop (may need re-setting between sessions)
- `wt merge` is configured: squash + commit + auto-remove worktree
- commit messages generated via `claude -p` (worktrunk config)
- worktrees land in `~/.claude/worktrees/<name>/`

## workflow

### 1. start session

```
claude --worktree <name> --tmux=classic
```

- creates worktree at `~/.claude/worktrees/<name>/`
- branch: `worktree-<name>` (based off current HEAD)
- tmux session with claude running inside
- all CLAUDE.md files loaded, auto-memory accessible

### 2. work

- stage files individually (never `git add .`)
- commit format: `{type}({phase}-{plan}): {description}`

### 3. merge to develop

```
wt merge
```

- works from inside or outside the worktree (auto-detects)
- single commit: fast-forwards directly; multiple commits: squashes
- generates commit message via `claude -p` (when squashing)
- auto-removes the worktree + branch, switches cwd to `~/claude`
- verify: `git log -1` from `~/claude`

### 4. ship

from `~/claude` (develop):

```
gh pr create --base master
```

- batches multiple worktree merges into one PR
- master is the only branch that pushes to origin

## observed: first session

Ran `claude --worktree this-seems-to-work --tmux=classic` from `~/claude` (2026-03-10):

- worktree at `~/.claude/worktrees/this-seems-to-work/`, branch `worktree-this-seems-to-work`
- based off master at f8b1fb0
- tmux session started, claude running, all context loaded
- `wt list` shows all worktrees, `gita ll` shows the claude repo
- `wt` initially warned about missing local master — fixed by setting default-branch to develop

## observed: wt merge from inside worktree (2026-03-10)

tested running `wt merge` from inside `~/.worktrees/test-merge-from-inside/`:

- **works.** merges commit(s) to develop, removes worktree+branch, switches cwd to `~/claude`
- with 1 commit and no squash needed, output: `Merged to develop (1 commit, 1 file, +1)`
- with 0 new commits: `Already up to date with develop` — still removes worktree cleanly
- after merge, you're back in `~/claude` on develop — `git log -1` confirms the merge

## observed: wt merge behavior details (2026-03-10)

- single commit: fast-forwarded directly, no squash/rebase needed
- zero commits: no-op merge, worktree still cleaned up
- `wt merge` auto-detects which worktree you're in — no need to specify branch name
- branch mismatch warning if worktree path doesn't match expected pattern (cosmetic, still works)

## observed: claude --worktree reuse (2026-03-10)

tested `claude --worktree test-reuse` when worktree `test-reuse` already existed:

- **reuses the existing worktree.** does not error or create a duplicate
- runs claude in the existing worktree directory
- `git worktree list` shows same single entry before and after

## observed: wt default-branch config (2026-03-10)

- config can get cleared between sessions — `wt` warns `Configured default branch master does not exist locally`
- fix: `wt config state default-branch set develop`
- `wt switch --create <name>` creates branch from current HEAD (develop), not master

## answered questions

| question | answer |
|----------|--------|
| `wt merge` from inside worktree? | yes — auto-detects worktree, merges, removes, switches to develop |
| resume after `wt merge` kills session? | you're back in `~/claude` on develop — just start a new session or continue working |
| `claude --worktree` reuse existing? | yes — reuses existing worktree, doesn't create duplicate |
