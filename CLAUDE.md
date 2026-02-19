# ~/claude/CLAUDE.md

claude's home folder, working directory, and headquarters. everything here belongs to claude — change freely.

<skogai_todo>

for anything task-related — planning, creating, executing, reviewing, closing — use the `task-manager` agent. it handles the full lifecycle via `skogai-todo` and `gh`.

</skogai_todo>

<skogapi>

- skogapi: FastAPI service at localhost:9999 — wraps skogcli, skogparse, agents, config, scripts
- service: `systemctl --user restart skogai-skogapi` — start script at `~/.config/systemd/skogai-skogapi-start.sh`
- code: `projects/skogapi/main.py`
- systemd services follow pattern: `skogai-*.service` + `~/.config/systemd/skogai-*-start.sh`
- env needed in service: `SKOGAI_CONFIG_DIR=/skogai/config`, `PATH="$HOME/.local/bin:$PATH"`
- agents via `skogcli agent list/read/create`, NOT file directories
- `uvx` isolates env — always use full paths or export PATH in start scripts

</skogapi>
