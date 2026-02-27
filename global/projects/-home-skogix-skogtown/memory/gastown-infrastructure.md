# Gas Town Infrastructure Notes

## Dolt Database
- Binary installed at `~/.local/bin/dolt` (v1.82.4, downloaded manually)
- Not installed system-wide (needs `sudo pacman -S dolt`)
- **CRITICAL**: `bd` (beads CLI) crashes with SIGSEGV in embedded mode
  - Fix: `export BEADS_DOLT_MODE=server` before any `bd` commands
  - Root cause: bd embeds dolt v0.40.5 library, incompatible with dolt v1.82.4 data format on disk
  - Needs to be added to `~/.zshrc` for persistence

## Formulas
- Formula files live in `/home/skogix/dev/gastown/.beads/formulas/` (32 formulas)
- Symlinked to `/home/skogix/skogtown/.beads/formulas` for workspace access
- Without this symlink, `bd formula list` and `bd mol wisp` find nothing

## Known Issues (2026-02-21)
- Wisp vapor phase: `bd mol wisp` reports success but wisps not queryable via `bd show`/`bd mol show`/`bd list`. ephemeral.sqlite3 stays empty.
- Mail send: `gt mail send <agent>/` fails with "no agent found" even though `gt agent list` shows Mayor and Deacon registered
- Patrol workaround: Execute mol-deacon-patrol steps manually by reading formula with `bd formula show`
