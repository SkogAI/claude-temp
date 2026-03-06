# gptme-whatsapp

## Purpose

WhatsApp integration for gptme agents via whatsapp-web.js. A Node.js bridge receives incoming WhatsApp messages and spawns either gptme or Claude Code to generate responses, sending them back via WhatsApp. Conversation history is maintained per-sender through named conversations (gptme) or `--resume` (Claude Code). Includes a Python helper package for setup and systemd service generation.

## CLI Commands

| Command | Description |
|---|---|
| `gptme-whatsapp-setup install` | Install npm dependencies in the `node/` directory |
| `gptme-whatsapp-setup service` | Generate a systemd user service file. Options: `--agent`, `--workspace`, `--contacts`, `--node-path`, `--backend` (gptme/claude-code), `--claude-path` |

The main bridge is a Node.js process, not a Python CLI:
```bash
cd packages/gptme-whatsapp/node
GPTME_AGENT=sven BACKEND=gptme node index.js
```

## Python API

### Setup: `gptme_whatsapp.setup`

| Function | Description |
|---|---|
| `check_node()` | Verify Node.js >= 18 is available |
| `install_npm_deps()` | Run `npm install` in the node/ directory |
| `generate_systemd_service(agent_name, workspace, allowed_contacts, node_path, backend, claude_path)` | Generate systemd service file content |
| `main()` | Click CLI group entry point |

### Node.js Bridge: `node/index.js`

The core runtime. ES module using whatsapp-web.js:

| Function | Description |
|---|---|
| `callAgent(sender, message)` | Route to appropriate backend |
| `callGptme(sender, message)` | Spawn `gptme -p <msg> --name whatsapp-<agent>-<sender> --non-interactive -y --workspace <path>` |
| `callClaudeCode(sender, message)` | Spawn `claude -p <msg> --output-format text --resume whatsapp-<agent>-<sender> --append-system-prompt-file <file>` |
| `spawnAndCapture(cmd, args, responseExtractor)` | Generic subprocess spawner with 120s timeout. Closes stdin immediately. Clears CLAUDECODE env var to prevent nesting |
| `extractResponse(output)` | Parse gptme stdout to extract last assistant response |

Key behaviors:
- Skips group messages and non-text messages
- Allowlist filtering by phone number
- QR code auth on first run, persisted in `.wwebjs_auth/`
- WhatsApp 4096 char limit enforced (truncates)
- Graceful shutdown on SIGTERM/SIGINT

## Setup Requirements

- **Node.js >= 18**: For whatsapp-web.js bridge
- **npm**: For installing dependencies
- **Puppeteer/Chrome**: whatsapp-web.js uses headless Chrome (may need swap on low-memory servers)
- **Phone/SIM**: Dedicated phone for the agent, or link as secondary device
- **QR code scan**: First run requires scanning QR with WhatsApp phone
- **gptme** or **Claude Code**: One must be installed as the agent backend
- **Python >= 3.10**: For the setup helper only

## Configuration

| Env Var | Default | Description |
|---|---|---|
| `GPTME_AGENT` | `sven` | Agent name (used in conversation naming) |
| `BACKEND` | `gptme` | Agent backend: `gptme` or `claude-code` |
| `AGENT_WORKSPACE` | `~/<agent>` | Path to agent's workspace directory |
| `ALLOWED_CONTACTS` | `""` (all) | Comma-separated phone numbers (international format, no `+`) |
| `GPTME_CMD` | `gptme` | Path to gptme binary |
| `CLAUDE_CMD` | `claude` | Path to claude binary |
| `SYSTEM_PROMPT_FILE` | `<workspace>/state/system-prompt.txt` | System prompt for Claude Code backend |

For Claude Code backend, generate the system prompt first:
```bash
cd /path/to/agent-workspace
./scripts/build-system-prompt.sh > state/system-prompt.txt
```

## Dependencies

### Python (setup helper)
- `click>=8.0`
- Build: `hatchling`

### Node.js (bridge)
- `whatsapp-web.js ^1.26.0` (WhatsApp Web protocol client)
- `qrcode-terminal ^0.12.0` (QR code display for auth)
- Implicit: Puppeteer (pulled by whatsapp-web.js)

## Claude Code Integration

**Full support as a backend.** When `BACKEND=claude-code`:

- Spawns: `claude -p "<message>" --output-format text --resume "whatsapp-<agent>-<sender>"`
- Injects agent identity via `--append-system-prompt-file`
- Conversation history persists via `--resume` with per-sender conversation IDs
- Strips CLAUDECODE env var to prevent nesting when running under Claude Code
- Closes stdin immediately to prevent SIGSTOP in non-interactive contexts
- 120 second timeout per message

## Key Source Files

| File | Purpose |
|---|---|
| `node/index.js` | Main WhatsApp bridge — whatsapp-web.js client, message handling, gptme/claude-code spawning, response extraction |
| `node/package.json` | Node.js dependencies (whatsapp-web.js, qrcode-terminal) |
| `node/sven-whatsapp.service.example` | Example systemd service file |
| `src/gptme_whatsapp/__init__.py` | Python package metadata |
| `src/gptme_whatsapp/setup.py` | Python CLI — Node.js check, npm install, systemd service generation |
| `tests/__init__.py` | Test package (empty) |
| `tests/test_setup.py` | Setup tests |
