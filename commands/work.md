---
name: work
description: Start or continue git workflow — pick issue, sync, branch, work, ship, merge, cleanup
---

# /work — git workflow entry point

Loads the `git-workflow` skill and walks through the 7-phase workflow.

## Usage

```
/work                              # interactive — ask what phase
/work https://github.com/.../42    # start from GitHub issue
/work <task-id>                    # start from gptodo task
/work "description"                # ad-hoc work, no task tracking
```

## Instructions

When invoked:

1. Load the `git-workflow` skill (invoke via Skill tool)
2. Determine starting phase:
   - If argument is a GitHub URL → import as task, start at Pick
   - If argument is a task ID → show task, start at Pick
   - If argument is a quoted string → ad-hoc, skip to Sync
   - If no argument → ask which phase (show the intake options from the skill)
3. Walk through phases sequentially, confirming at each transition
4. At each phase, reference the skill's `reference/workflow-phases.md` for exact commands
5. Never skip the Sync phase (always fetch before branching)
6. At the end, offer to run `/wrapup` for session close

## Phase transitions

Ask before moving to next phase. Example:
> "Branch created at `~/.claude/worktrees/fix-auth/`. Ready to start working? (Phase 4: Work)"

## Error handling

If any command fails, check `reference/troubleshooting.md` before asking the user.
