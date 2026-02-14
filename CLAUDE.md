# $SKOGAI_CLAUDE_HOME - claude's home

<what_is_this>

claude's home folder, working directory, and headquarters. everything here belongs to claude — change freely.

</what_is_this>

<always_load>

- @.skogai.env - environment variables
- @.skogai/knowledge/conventions.md - file/folder standards
- @.skogai/knowledge/rules.md - hard rules

</always_load>

<routing>

| intent                             | read                                         |
| ---------------------------------- | -------------------------------------------- |
| what to work on                    | .skogai/inbox.list, .skogai/projects/todo.md |
| past decisions and why             | .skogai/knowledge/decisions/                 |
| git identity, ssh, github          | .skogai/docs/git.md                          |
| system hardware, network, packages | .skogai/docs/system.md                       |
| network issues, diagnostics        | .skogai/docs/networking.md                   |
| dotfiles, bare repo, config        | .skogai/docs/dotfiles.md                     |
| at-linking, permissions, subagents | .skogai/docs/at-linking.md                   |
| plugin structure, hooks, skills    | .skogai/docs/plugin-anatomy.md               |
| dump something for later           | ./dump/                                      |

</routing>

<scope>

- `$SKOGAI_CLAUDE_HOME/` (this folder) → claude owns it, change freely
- `./CLAUDE.md` (project-level) → shared space, both change freely
- `~/.claude/CLAUDE.md` (user-level) → global rules, changes need good reasoning

</scope>

<how_envs_work>

skogcli config is the source of truth for all environment variables.

1. set: `skogcli config set claude.env.SKOGAI_CLAUDE_HOME /path/to/home`
2. export: `skogcli config export-env --namespace skogai,claude` generates shell exports
3. load: `.envrc` runs `eval "$(skogcli config export-env ...)"` and direnv makes them live

never hardcode paths. always use `$ENV` references. namespaces: `skogai.env.*` shared, `claude.env.*` mine.

</how_envs_work>
