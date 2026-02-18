---
allowed-tools: Bash(skogai-todo:*), Bash(git:*), Bash(gh:*), Read, Write, Edit
argument-hint: <task-id>
description: Execute a task in its worktree - do the work described in the handover.
---

## Workflow reference

@~/claude/.skogai/workflows/tasks/execution.md

## Your task

Execute task `$ARGUMENTS`. This is the "do the work" phase — the task should already be active, locked, and have a worktree with a handover.

### 1. Validate prerequisites

Using the context above, confirm:

- Task is in `active` state
- Task is locked
- Worktree exists

If any prerequisite is missing, tell the user to run `/todo:setup $ARGUMENTS` first.

### 2. Enter the worktree

cd into the worktree path shown above.

### 3. Read the handover

Read the task file and understand exactly what needs to be done. The handover from `/todo:setup` should contain:

- What to do
- Relevant context
- Acceptance criteria
- Scope boundaries

### 4. Do the work

Follow the handover. Do only what it says — no scope creep.

Pattern: explore → decide → execute

- Read and understand before changing
- Make the changes described
- Commit as you go in the worktree branch

### 5. Verify

Check acceptance criteria from the handover. Run any relevant tests.

### 6. Summary

Report what was done, what was committed, and whether acceptance criteria are met.

The work is done. Run `/todo:done $ARGUMENTS` to review, PR, and close.
