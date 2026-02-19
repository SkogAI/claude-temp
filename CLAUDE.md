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

## Project Structure

- @.claude-plugin/ - Plugin configuration (plugin.json, marketplace.json)
- @commands/ - Custom slash commands (plugin component)
- @docs/claude-code/ - Extensive Claude Code documentation
- @docs/skogix/ - User documentation (definitions.md, user.md)
- @skills/ - Custom skills for Claude Code (plugin component)
  - @skills/claude-code-modifications/SKILL.md - main project skill
  - @skills/claude-code-modifications/scripts/update-plugins.sh - plugin update/reload
- @lessons/ - Keyword-triggered behavioral lessons (gptme format, injected via hooks)
- @JOINK/ - Reference implementation of lesson system from gptme

## Tools

- NEVER use sed or awk -- use proper tools (yq, jq, etc.)
- `yq --front-matter=extract '<query>' file.md` -- parse YAML frontmatter from markdown
- when a tool version is wrong, ask skogix to install the correct one

## Lessons System

- @lessons/ contains keyword-triggered behavioral lessons (gptme format)
- lessons are NOT skills -- they are small contextual injections ("hey remember this")
- @JOINK/ has the reference implementation (python lesson system from gptme)
- don't touch lesson content, don't reorganize lessons -- build the injection mechanism
