---
allowed-tools: Bash(skogai-todo:*), Bash(git:*), Bash(gh:*), Read, Write, Edit
argument-hint: <task-id>
description: Close out a task - review, PR, unlock, sync, and remove worktree.
---

## Your task

Close out task `$ARGUMENTS`. This is the "done" phase — review the work, create a PR, and clean everything up.

### 1. Validate

Using the context above, confirm the task exists and has a worktree with commits.

### 2. Review the changes

Look at the commits and diff in the worktree branch. Confirm the work matches the task's acceptance criteria. Flag anything that looks wrong.

### 3. Create PR or merge

Default to PR for review:

`skogai-todo worktree pr $ARGUMENTS`

For trivial changes, ask the user if they'd prefer a direct merge:

`skogai-todo worktree merge $ARGUMENTS`

### 4. Unlock

`skogai-todo unlock $ARGUMENTS`

### 5. Set state to done

`skogai-todo edit $ARGUMENTS --set state done`

### 6. Sync with GitHub

`skogai-todo sync --update`

### 7. Clean up worktree

`skogai-todo worktree remove $ARGUMENTS`

### 8. Summary

```
task:      $ARGUMENTS
state:     done
PR:        <url or "merged directly">
worktree:  removed
github:    synced
```
