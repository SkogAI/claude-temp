# tool commands — CLI quick-reference

## gita (multi-repo)

| Command | Purpose |
|---------|---------|
| `gita ll` | Status of all repos (branch, dirty, ahead/behind) |
| `gita ll <group>` | Status for specific group |
| `gita fetch` | Fetch all repos |
| `gita pull` | Pull all repos |
| `gita fetch <repo>` | Fetch specific repo |
| `gita super <repo> <git-cmd>` | Run git command on specific repo |
| `gita shell <repo> <cmd>` | Run shell command in repo directory |
| `gita ls <repo>` | Get absolute path of a repo |
| `gita group ll` | Show groups with their repos |
| `gita context <group>` | Set context to scope commands |
| `gita freeze` | Export repo state for backup |

## wt (worktrunk — worktree lifecycle)

| Command | Purpose |
|---------|---------|
| `wt switch --create <branch>` | Create new branch + worktree |
| `wt switch --create <branch> --base <ref>` | Create from specific base |
| `wt switch -x claude -c <branch> -- '<prompt>'` | Create + launch Claude |
| `wt switch <branch>` | Switch to existing worktree |
| `wt switch -` | Switch to previous worktree |
| `wt switch ^` | Switch to default branch |
| `wt switch pr:123` | Switch to PR's branch |
| `wt list` | List worktrees with status |
| `wt merge` | Squash + rebase + ff-merge + cleanup |
| `wt merge <target>` | Merge into specific branch |
| `wt merge --no-squash` | Preserve commit history |
| `wt merge --no-remove` | Keep worktree after merge |
| `wt merge -y` | Skip approval prompts |
| `wt remove` | Remove current worktree + branch |
| `wt remove <branch>` | Remove specific worktree |
| `wt remove -D` | Force-delete unmerged branch |
| `wt step commit` | Commit with LLM message generation |
| `wt config show` | Show configuration |

## gptodo (task tracking)

| Command | Purpose |
|---------|---------|
| `gptodo list` | List tasks |
| `gptodo list --state new --priority high` | Filter by state + priority |
| `gptodo show <task-id>` | Show task details |
| `gptodo edit <task-id> --set state active` | Set task active |
| `gptodo edit <task-id> --set state done` | Mark task done |
| `gptodo import --source github --repo <owner/repo>` | Import GitHub issues |
| `gptodo import --source github --repo <owner/repo> --state open` | Import open issues |
| `gptodo fetch --all` | Refresh external issue states |
| `gptodo sync --update --use-cache` | Sync task states |
| `gptodo status` | Overview of all tasks |
| `gptodo spawn <task-id> --backend claude` | Spawn sub-agent |

## gh (GitHub CLI)

| Command | Purpose |
|---------|---------|
| `gh issue list -R <owner/repo>` | List issues |
| `gh issue view <number> -R <owner/repo>` | View issue details |
| `gh pr create --base master --title "..." --body "..."` | Create PR |
| `gh pr create --base master --draft` | Create draft PR |
| `gh pr list` | List PRs |
| `gh pr view <number>` | View PR details |
| `gh pr merge <number>` | Merge PR |

## git (standard ops)

| Command | Purpose |
|---------|---------|
| `git fetch origin` | Fetch from remote |
| `git push -u origin HEAD` | Push branch + set upstream |
| `git push` | Push (after local merge to master) |
| `git add <file1> <file2>` | Stage specific files |
| `git status` | Check working tree |
