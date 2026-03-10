# Git Branching Model — claude repo

## Layout

- `~/.local/src/claude` — main repo, checked out on `master`
- `~/claude` — worktree, checked out on `master`
- Single remote: `origin` → `git@github.com:SkogAI/claude.git`

## Branch roles

- **`master`** (`refs/heads/master`): the one true source. Only branch that talks to origin. All PRs target master.
- **Feature branches** (`worktree-<name>`): temporary worktrees. Push to origin, PR against master, clean up after merge.

## Flow

```
feature worktree ──git push──→ origin/worktree-<name> ──PR──→ master
```

## Rules

- No develop branch. Worktrees PR directly against master.
- Only master is permanent. All other branches are temporary.
- `wt config state default-branch set master`.
- `wt merge` for trivial local changes (fast-forward into master, then push).
- PRs for anything that benefits from review or CI.
