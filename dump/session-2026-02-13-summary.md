---
title: session summary 2026-02-13
type: session-summary
date: 2026-02-13
project: ~/dev/init
---

# session summary: bootstrapping claude's home and skogai env system

## what we built

1. **claude's home** at `$SKOGAI_CLAUDE_HOME` (`/home/skogix/docs/claude/`)
   - `CLAUDE.md` - scope rules (home=free, project=shared, global=argue for it), how envs work
   - `agent.md` - constraints, failure modes, work preferences, env references
   - `dump/` - async notes for later review

2. **environment system** via `skogcli config`
   - `skogai.env.*` - shared namespace, loaded at bootstrap by all agents
   - `claude.env.*` - claude-specific, overrides shared defaults
   - namespace layering: later namespaces win (`--namespace skogai,claude`)
   - `.envrc` runs `eval "$(skogcli config export-env --namespace skogai,claude)"`

3. **skogcli scripts**
   - `generate-env` - produces `.skogai.env` snapshot with timestamp from config
   - `demo` - agent context output (single string, literal `\n`)
   - `dump` - append async notes to `$SKOGAI_CLAUDE_DUMP/YYYY-MM-DD.md`
   - `env` - resolve env var by name via `${!1}`
   - `date` - ISO timestamp
   - `transform-message` - text in, text out filter via skogparse

4. **skogparse pipeline**
   - `$` = reference (type: ref), `@` = action (type: action)
   - `.` = belonging/traversal, `:` = continuation
   - `skogparse` evaluates, `skogparse-bin` gives AST only
   - config IS the type system IS the parser vocabulary
   - single string in, single string out contract

5. **bootstrap loop**
   - `.envrc` loads envs AND runs `generate-env` on project enter
   - `CLAUDE.md` references `@.skogai.env` so env context loads every session
   - stop hook wired in `plugins/core/hooks/stop.sh` (transcript extraction needs work)

## key lessons

- json is text. one input one output. literal `\n` not actual newlines
- don't use tools (jq, sed, pipes) without understanding implications
- run and verify before claiming things work
- skogparse expressions in messages = declarative actions, no scripts needed
- `[$ datetime, $ env.agent.home, $ pwd]` replaces the entire demo script

## dump items (unresolved)

- weaver needs to know agent.md path
- stale plan file at /skogai/config/claude/plans/ needs cleanup
- stop hook transcript jq extraction needs fixing
