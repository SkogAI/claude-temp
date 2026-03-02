# Claude Welcome Tour

Working memory for the SkogAI rebuild — fresh start, documented from scratch.

## What We Know So Far

**This repo (~/claude/)** is the meta-system: projects, scripts, global/ symlinks into ~/.claude/, dual-git observability.

**SkogAI** is the project we're rebuilding. Core idea: intelligent context routing for Claude Code sessions — get the *right* context at the *right* time instead of dumping everything at boot.

## What Exists Now

- `scripts/` — csync.sh (auto-commit hook), cgit.sh (bare repo wrapper), clog.sh (log viewer)
- `global/` — symlinks into ~/.claude/ (settings, projects, plans, todos, plugins, exclude). Skills deleted.
- `projects/skogapi/` — FastAPI service (routing data, agents, config). Status unknown.
- `projects/skogai-context/` — planning docs for the context routing system. Not implemented.
- `projects/newinstall/` — post-archinstall setup docs.
- `.skogai/` — legacy local context (DECISIONS.md, RULES.md, email system, journal, todo archive). "Probably doesn't make sense with current context but we will get there."

## What's Been Removed

- `global/skills/` — all skills deleted (routing, agent-prompting, argc, fleet-memory, nelson)
- `projects/skogai-core/` — plugin scaffold deleted

## Unresolved References (to clarify or remove)

- **rtk** — command rewrite hook (`global/hooks/rtk-rewrite.sh`). What is it?
- **beads/br** — issue tracking referenced in /wrapup command. What is it?
- **~/skogai/** — external repo referenced in context docs. Will set up together.
- **soul document** — identity layer referenced in skogai-context planning.
- **bare repo** (`/mnt/sda1/claude-global.git`) — is it live on this install?

## Tour Progress

1. [x] Init — explored repo, wrote root CLAUDE.md
2. [x] Context audit — shared what I see vs what's opaque
3. [x] Cleanup — deleted stale skills and skogai-core
4. [ ] Walk through remaining pieces together
5. [ ] Set up ~/skogai and related paths
6. [ ] Clarify or remove stale references
7. [ ] Rebuild skills/plugins from scratch with full understanding
