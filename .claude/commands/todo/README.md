# todo command family

Four slash commands that automate the full task lifecycle using `skogai-todo`.

## prerequisites

- `skogai-todo` CLI must be installed and on your PATH
- A git repository

## installation

### project-level (current project only)

```bash
cp -r generated-commands/todo .claude/commands/
```

### user-level (all projects)

```bash
cp -r generated-commands/todo ~/.claude/commands/
```

Restart Claude Code after copying.

## commands

| command | description |
|---|---|
| `/todo:plan` | big picture planning — review tasks, set priorities and dependencies |
| `/todo:setup <id>` | prepare a task for work — activate, lock, create worktree, enrich handover |
| `/todo:execute <id>` | do the work described in the task handover |
| `/todo:done <id>` | close out a task — review, PR, unlock, sync, clean up |

## workflow

```
/todo:plan
    review all tasks, fix priorities and dependencies, pick what to work on next

/todo:setup <id>
    activates the task, acquires a lock, creates a git worktree,
    and writes a concrete handover into the task file

/todo:execute <id>
    reads the handover, does the work in the worktree branch,
    commits as it goes

/todo:done <id>
    reviews commits against acceptance criteria, creates a PR,
    unlocks the task, marks it done, syncs with GitHub, removes the worktree
```

## state transitions

```
backlog → todo → active → ready_for_review → done
                 active → waiting → active → done
```

## notes

- `/todo:plan` requires no argument — it surveys all tasks
- `/todo:setup`, `/todo:execute`, and `/todo:done` take a task id
- locking prevents concurrent work on the same task
- one worktree per task — the worktree branch is named after the task
