# git-workflow

unified git workflow: worktree, workflow, pr, merge, issue, branch, ship, git flow

<what_is_this>

unified git workflow skill for the skogai development environment. encapsulates the full cycle from picking an issue through shipping code: issue selection, upstream sync, worktree creation, development, commit, push, PR, merge, and cleanup. orchestrates `gita`, `wt`, `gptodo`, `gh`, and `git` into a single coherent process.

</what_is_this>

<essential_principles>

- **master is the only branch that talks to origin** — all PRs target master
- **no develop branch** — worktrees PR directly against master
- **worktree branches are temporary** — removed after merge, never long-lived
- **stage files individually** — never `git add .` or `git add -A`
- **commit format:** `{type}({phase}-{plan}): {description}` — types: feat, fix, test, refactor, docs, chore
- **use `wt` for worktree ops** — not `gptodo worktree` (wt is the primary tool)
- **idempotent where possible** — safe to run twice, skip what's done, fix what's missing

</essential_principles>

<workflow>

1. **Pick** — select task or issue (`gptodo list`, `gh issue list`, or a URL)
2. **Sync** — fetch upstream (`gita fetch` for all repos, or `git fetch origin`)
3. **Branch** — create worktree (`wt switch --create <branch>`, or `claude --worktree <name> --tmux=classic`)
4. **Work** — code, test, commit loop (stage individually, atomic commits)
5. **Ship** — push + open PR (`git push -u origin HEAD`, `gh pr create --base master`)
6. **Merge** — `wt merge` for local fast-forward, or merge via GitHub PR
7. **Cleanup** — remove worktree (`wt remove`), mark task done (`gptodo check`)

</workflow>

<routing>

| need | read |
|------|------|
| CLI commands for all tools | reference/tool-commands.md |
| detailed phase instructions | reference/workflow-phases.md |
| something went wrong | reference/troubleshooting.md |
| wt deep dive | @~/.local/src/worktrunk/skills/worktrunk/SKILL.md |
| gptodo deep dive | @~/claude/skills/gptme/SKILL.md |

</routing>

<intake>

What phase are you at?

- **"I have a GitHub issue URL"** — start at Pick
- **"I have a task ID"** — start at Pick
- **"I need to sync all repos"** — start at Sync
- **"I have a worktree ready"** — start at Work
- **"I'm ready to ship"** — start at Ship
- **"PR is merged, need cleanup"** — start at Cleanup

</intake>
