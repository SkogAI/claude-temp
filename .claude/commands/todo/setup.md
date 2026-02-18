---
allowed-tools: Bash(skogai-todo:*), Bash(git:*), Bash(gh:*), Read, Write, Edit
argument-hint: <task-id>
description: Prepare a task for execution - activate, lock, create worktree, enrich task file.
---

## Context

- Current locks: !`skogai-todo locks`
- Existing worktrees: !`skogai-todo worktree list`
- Task state transitions: !`skogai-todo transitions`

## Workflow reference

@~/claude/.skogai/workflows/tasks/preparation.md

## Your task

Prepare task `$ARGUMENTS` for execution. This is the "setup" phase — everything that needs to happen before work begins.

### 1. Validate

Using the context above, confirm the task exists and check its current state. If the task id is empty or doesn't exist, stop and tell the user.

### 2. Set state to active

Run `skogai-todo edit $ARGUMENTS --set state active`

### 3. Lock the task

Run `skogai-todo lock $ARGUMENTS`

If the lock fails (already locked), warn the user and ask whether to force (`--force`) or abort.

### 4. Create a worktree

Run `skogai-todo worktree create $ARGUMENTS`

### 5. Enrich the task file

Read the task file and any linked issues, parent tasks, or referenced files. Update the task file with a handover:

- What needs to be done (concrete, not vague)
- Relevant context (files, decisions, constraints)
- Acceptance criteria (how to know it's done)
- What NOT to do (scope boundaries)

### 6. Summary

Print a short status report:

```
task:      $ARGUMENTS
state:     active
locked:    yes
worktree:  <path>
```

Plus a brief summary of the key context discovered during enrichment.

The task is now ready for `/todo:execute`.
