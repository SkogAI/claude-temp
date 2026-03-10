# git workflow: worktree → PR → master

## goal

1. an issue is chosen
2. a worktree is created (branch off master)
3. we do work in the worktree
4. push worktree branch, PR against master
5. merge PR, clean up worktree

## tools

| tool | role |
|------|------|
| `claude --worktree <name> --tmux=classic` | create worktree + tmux + start claude |
| `wt` (worktrunk) | worktree lifecycle: list, merge, remove |
| `gita` | multi-repo overview (`gita ll`) |
| `gh` | PRs against master |

## setup

- `wt config state default-branch set master` — so `wt merge` targets master
- worktrees land in `~/.claude/worktrees/<name>/`

## workflow

### 1. start session

```
claude --worktree <name> --tmux=classic
```

- creates worktree at `~/.claude/worktrees/<name>/`
- branch: `worktree-<name>` (based off master)
- tmux session with claude running inside

### 2. work

- stage files individually (never `git add .`)
- commit format: `{type}({phase}-{plan}): {description}`

### 3. ship

from the worktree:

```
git push -u origin HEAD
gh pr create --base master
```

- each worktree becomes one PR against master
- after merge, clean up: `wt remove` or `git worktree remove`

### 4. alternative: wt merge for local fast-forward

if the change is trivial and doesn't need PR review:

```
wt merge
```

- merges worktree branch directly into master
- auto-removes worktree + branch
- then `git push` from master

## rules

- master is the only branch that talks to origin
- no develop branch — worktrees PR directly against master
- worktree branches are temporary — removed after merge
