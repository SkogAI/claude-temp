# Claude Code Built-in Tools

## Core (file operations)
- **Read** — read file contents (text, images, PDFs, notebooks)
- **Write** — create or overwrite files
- **Edit** — exact string replacements in existing files
- **Glob** — file pattern matching (wraps fd/find)
- **Grep** — content search (wraps ripgrep)
- **NotebookEdit** — edit Jupyter notebook cells

## Execution
- **Bash** — shell command execution (sandboxed)
- **KillShell** — kill background bash shells
- **TaskOutput** — retrieve output from background tasks
- **Sleep** — wait/sleep with early wake on user input

## Agents & Tasks
- **Task** (aka Agent) — launch sub-agents for complex multi-step tasks
- **TaskCreate** — create a new task
- **TaskGet** — retrieve task details
- **TaskList** — list all tasks with status
- **TaskUpdate** — update task status/dependencies/details
- **TodoWrite** — break down and manage work with task lists

## Planning
- **EnterPlanMode** — explore and design implementation approaches
- **ExitPlanMode** — present plan for user approval, start coding

## Web
- **WebFetch** — fetch content from a URL
- **WebSearch** — web search with domain filtering

## User Interaction
- **AskUserQuestion** — ask multiple-choice questions for requirements/clarification
- **Skill** — execute a skill in the main conversation

## Swarm / Multi-Agent
- **SendMessageTool** — send messages to teammates, handle protocol requests/responses
- **TeammateTool** — manage teams and coordinate teammates
- **TeamDelete** — delete a teammate

## Code Intelligence
- **LSP** — language server protocol: type errors, jump to definition, find references, symbols

## Tool Discovery
- **MCPSearch** — search for and load MCP tools on demand
- **ToolSearch** — search and load deferred built-in tools

## Environment
- **Computer** — Chrome browser automation
- **EnterWorktree** — git worktree management
