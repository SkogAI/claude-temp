#!/bin/bash
# @describe Claude Code workspace manager
# @env GPTODO_TASKS_DIR=/home/skogix/claude/.skogai/tasks  Tasks directory

# @cmd Worktree management commands
workspace() {
  :
}

# @cmd Open an existing worktree session
# @arg name![`_choice_worktrees`] Worktree to open
# @flag --claude  Launch claude in the worktree
workspace::open() {
  # wt switch "$argc_name"
  if [[ "$argc_claude" == "1" ]]; then
    claude --worktree "$argc_name" --tmux=classic
  else
    echo "Not implemented yet, use 'wt switch $argc_name' to manually switch to the worktree"
  fi
}

# @cmd Create a worktree from a gptodo task
# @arg task_id![`_choice_tasks`] Task to create worktree for
# @flag --claude  Launch claude in the worktree
workspace::create() {
  gptodo worktree create "$argc_task_id"
  wt switch "task-${argc_task_id}"
  if [[ "$argc_claude" == "1" ]]; then
    claude --worktree "task-${argc_task_id}" --tmux=classic
  fi
}

# @cmd List all git worktrees
# @alias ls
workspace::list() {
  _choice_worktrees
}

# @cmd Remove a worktree by name
# @alias rm
# @arg name![`_choice_worktrees`] Worktree name
workspace::remove() {
  git worktree remove "$(_worktree_path "$argc_name")"
}

# @cmd Push worktree branch and create PR against master
# @option -t --title  PR title
# @option -b --body   PR body
workspace::ship() {
  local branch
  branch=$(git branch --show-current)

  if [[ "$branch" == "master" ]]; then
    echo "error: already on master, nothing to ship" >&2
    return 1
  fi

  git push -u origin HEAD
  if [[ -n "$argc_title" ]]; then
    gh pr create --base master --title "$argc_title" --body "${argc_body:-}"
  else
    gh pr create --base master --fill
  fi
}

# @cmd Merge current worktree into master (for trivial changes)
workspace::merge() {
  wt merge
}

# @cmd Prune stale worktree references
workspace::prune() {
  git worktree prune
}

# @cmd Show interface for all commands
debug() {
  :
}

# @cmd Show interface for all commands
# @flag --json  Output raw JSON (argc-export)
debug::interface() {
  local script
  script=$(argc --argc-script-path)

  if [[ "$argc_json" == "1" ]]; then
    argc --argc-export "$script"
    return
  fi

  (eval "$(argc --argc-eval "$script" --help)") 2>&1
  echo "---"

  argc --argc-export "$script" | jq -r '
    .subcommands[] |
    (.name as $p | $p, (.subcommands[]? | $p + " " + .name))
  ' | while IFS= read -r cmd; do
    # shellcheck disable=SC2086
    (eval "$(argc --argc-eval "$script" $cmd --help)") 2>&1
    echo "---"
  done
}

_worktree_path() {
  git worktree list --porcelain | awk -v name="$1" '/^worktree/ && $2 ~ name"$" {print $2}'
}

_in_worktree() {
  ! test -d .git
}

_choice_worktrees() {
  git worktree list 2>/dev/null |
    awk 'NR>1 {print $1}' |
    xargs -I{} basename {}
}

_choice_tasks() {
  gptodo list --json 2>/dev/null |
    jq -r '.tasks[].id'
}

eval "$(argc --argc-eval "$0" "$@")"
