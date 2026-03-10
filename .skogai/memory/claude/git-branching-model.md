# Git Branching Model — claude repo

## Layout

- `~/.local/src/claude` — main repo, checked out on `master`
- `~/claude` — worktree, checked out on `develop`
- Single remote: `origin` → `git@github.com:SkogAI/claude.git`

## Refs (what they are, literally)

- `refs/heads/*` — local branches. Files on disk holding a SHA. `HEAD` points to one of these.
- `refs/remotes/origin/*` — snapshots of the remote. Only updated by `git fetch`/`git pull`. Never touched by local commits.
- `FETCH_HEAD` — written by `git fetch`. Lists every fetched branch. Only branches without `not-for-merge` are merge-eligible. Currently only `master` is merge-eligible.

## Branch roles

- **`master`** (`refs/heads/master`): the one true source. Only branch that talks to origin. Config: `remote = origin`, `merge = refs/heads/master`. Changes reach GitHub via `git push` or PRs.
- **`develop`** (`refs/heads/develop`): permanent worktree workspace at `~/claude`. Integration branch. Feature branches merge here via `wt merge`. Does NOT need remote tracking (git auto-adds it on push — ignore it).
- **Feature branches**: temporary worktrees. Merge into develop via `wt merge`. Never pushed to origin. No remote tracking needed.

## Flow

```
feature worktree ──wt merge──→ develop ──merge──→ refs/heads/master ──git push──→ refs/remotes/origin/master
```

## Rules

- Only `master` pushes to origin. No other branch needs to exist on the remote.
- `develop` config in `.git/config` is noise — git auto-adds it. Don't rely on it, don't fight it.
- `wt merge` targets develop (worktrunk config: `default-branch = develop`).
- develop → master promotion is a separate step (merge + push).
- All the stale remote branches (test-worktree-*, worktree-claude-*, etc.) are cleanup candidates.

## Key git config (`.git/config`)

```
[remote "origin"]
    url = git@github.com:SkogAI/claude.git
    fetch = +refs/heads/*:refs/remotes/origin/*

[branch "master"]
    remote = origin
    merge = refs/heads/master
```

That's it. master tracks origin. Everything else is local.
