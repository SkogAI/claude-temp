# Auto Memory — ~/claude

## RTK (Rust Token Killer)

- **Version**: v0.22.2 (docs in .todo/ previously referenced v0.2.0 — now fixed)
- **Hook**: `~/.claude/hooks/rtk-rewrite.sh` — transparent PreToolUse rewrite, zero overhead
- **Setup**: `rtk init -g --auto-patch` installs hook + RTK.md + settings.json patch
- **Audit**: `rtk hook-audit` shows rewrite metrics; `rtk gain` shows savings
- **Discovery**: `rtk discover` analyzes Claude Code history for missed savings
- Old docs said ls (-274%) and grep (buggy) — both now work well (73%, 95%)
- `rtk init --show` gives full status of RTK integration health

## Claude Code Hooks

- PreToolUse hooks can **rewrite** commands via `updatedInput` in JSON output (not just deny)
- Format: `{ hookSpecificOutput: { permissionDecision: "allow", updatedInput: { command: "..." } } }`
- Hook receives stdin JSON: `{ tool_name, tool_input: { command }, ... }`
- Exit 0 = allow, exit 2 = block, JSON deny = block with reason
- Hooks registered in settings.json under `hooks` key, scoped by matcher regex
- `$CLAUDE_PROJECT_DIR` for project-relative paths in hook commands

## Beads

- `br` alias sometimes unavailable; `bd` is the reliable alias
- `bd sync` is deprecated — use `bd dolt push` / `bd dolt pull`
- Dolt server may be down; check with `bd dolt start` if needed

## Project Conventions

- `.todo/` = curated reference collection (hooks, skills, templates, docs)
- `todo/` = active review items
- RTK reference docs live at `.todo/rtk-optimized.md`
