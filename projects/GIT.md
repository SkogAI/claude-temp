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

- `wt config state default-branch set develop` — so `wt merge` targets develop
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

- squashes commits into develop
- generates commit message via `claude -p`
- auto-removes the worktree (kills tmux/claude session)
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

## open questions

- does `wt merge` from inside the worktree work, or must it be run from outside?
- after `wt merge` kills the session, how to cleanly resume in develop?
- can `claude --worktree` reuse an existing worktree, or always creates new?
