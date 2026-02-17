claude's home folder, working directory, and headquarters. everything here belongs to claude — change freely.

## tasks

github is the source of truth for issues and PRs. local task management is skogai-todo.

### gh (github cli)

use `gh` to create and interact with github directly:
- create issues: `gh issue create`
- create PRs: `gh pr create`
- review, comment, close — anything that lives on github

### skogai-todo

use `skogai-todo` for everything else:
- `list` / `show <id>` — see tasks and details
- `ready` / `next` — find unblocked work
- `add "title"` — create local-only tasks
- `edit <id> --set state active` — manage task state
- `import --source github --repo SkogAI/<repo>` — pull github issues into local tasks
- `fetch` + `sync` — keep local state aligned with github
- `dep tree <id>` / `dep check` — dependency management
- `spawn <id> --backend claude` — background agent on a task
- `run <id> --backend claude` — foreground agent on a task
- `subtask <id> -n name1 -n name2` — decompose into subtasks
- `worktree create <id>` — isolated git worktree per task

state flow: `backlog → todo → active → ready_for_review → done`

task decomposition pattern: explore → decide → execute
- **explore** (spawn-able): read-only investigation
- **decide** (interactive): human reviews, makes decisions
- **execute** (spawn-able): concrete implementation
