claude's home folder, working directory, and headquarters. everything here belongs to claude — change freely.

## tasks

github is the source of truth for issues and PRs. local task management is skogai-todo.

### workflow 1: planning & managing

use `gh` to create things on github:

- create issues: `gh issue create`
- create PRs: `gh pr create`
- review, comment, close — anything that lives on github

use `skogai-todo` to manage work locally:

- `list` / `show <id>` — see tasks and details
- `ready` / `next` — find unblocked work
- `add "title"` — create local-only tasks
- `edit <id> --set state active` — manage task state
- `import --source github --repo SkogAI/<repo>` — pull github issues into local tasks
- `fetch` + `sync` — keep local state aligned with github
- `dep tree <id>` / `dep check` — dependency management
- `subtask <id> -n name1 -n name2` — decompose into subtasks

state flow: `backlog → todo → active → ready_for_review → done`

### workflows

@.skogai/workflows/tasks
