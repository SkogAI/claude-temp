# troubleshooting

common issues and recovery for the git workflow skill.

## Merge conflicts during `wt merge`

`wt merge` rebases onto the target branch. If conflicts occur:
```bash
# Resolve conflicts in the files
git add <resolved-files>
git rebase --continue
# Then retry merge
wt merge
```

If rebase is too messy, abort and use PR workflow instead:
```bash
git rebase --abort
git push -u origin HEAD
gh pr create --base master
# Resolve conflicts in the PR
```

## Stale worktrees

Worktrees that were abandoned or whose branch was deleted:
```bash
wt list              # identify stale ones
wt remove <branch>   # try normal remove
wt remove -D <branch> # force if branch is unmerged
```

If `wt remove` fails:
```bash
git worktree remove --force <path>
git branch -D <branch>
```

## gptodo import date bug

`gptodo import` writes unquoted YAML dates (e.g., `created: 2026-03-06`). Fix:
```bash
sed -i 's/^created: \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$/created: "\1"/' tasks/*.md
```
Tracked: SkogAI/dot-skogai#6

## wt remove with untracked files

If worktree has untracked files, `wt remove` may refuse:
```bash
wt remove -f <branch>  # force removal
```

Or clean first:
```bash
cd <worktree-path>
git clean -fd
wt remove <branch>
```

## wt config state lost

`wt config state default-branch` may get cleared between sessions:
```bash
wt config state default-branch set master
```

## Push rejected (non-fast-forward)

If master has advanced since your branch:
```bash
git fetch origin
git rebase origin/master
# Resolve any conflicts
git push --force-with-lease
```

Or use `wt merge` which handles rebasing automatically.

## gita repo not found

If `gita super <repo> ...` says repo not found:
```bash
gita ls          # list registered repos
gita add <path>  # re-add if missing
```

## Wrong worktree path

User's worktrees should be in `~/.claude/worktrees/`. If wt creates elsewhere:
```bash
wt config show   # check template path
```

## Claude agent won't start in worktree

Strip nesting env vars when spawning sub-agents:
```bash
CLAUDECODE= CLAUDE_CODE_ENTRYPOINT= claude -p '<prompt>'
```
