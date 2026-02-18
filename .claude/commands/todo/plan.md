---
allowed-tools: Bash(skogai-todo:*), Bash(git:*), Bash(gh:*), Read, Write, Edit
description: Big picture planning - review all tasks, set dependencies, priorities, and ordering.
---

## Context

- All tasks: !`skogai-todo list`
- Ready (unblocked): !`skogai-todo ready`
- Dependency issues: !`skogai-todo dep check`
- Tags overview: !`skogai-todo tags`

## Your task

Big picture planning across all tasks. The goal is a clear, actionable plan — not just a summary.

### 1. Review the full picture

Using the context above, understand what exists: task states, dependencies, priorities, and gaps.

### 2. Dependency analysis

Run `skogai-todo dep tree` on key tasks to visualize the graph. Identify:

- Missing dependencies between tasks that should block each other
- Circular dependencies
- Tasks that can be parallelized

Set missing dependencies: `skogai-todo edit <id> --add depends <other-id>`

### 3. Priorities

Set priorities where missing or wrong: `skogai-todo edit <id> --set priority high|medium|low`

Consider: what unblocks the most work? what's on the critical path?

### 4. Task descriptions

For any task that's vague or missing detail, read the task file and enrich it with concrete descriptions, acceptance criteria, and scope boundaries.

### 5. Recommendation

End with a clear recommendation:

- What to work on next and why
- What can be parallelized
- What's blocked and what would unblock it
- Suggested ordering for the next batch of work

The plan is ready. Pick a task and run `/todo:setup <id>`.
