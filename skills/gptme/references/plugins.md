# gptme Plugins

## Overview

gptme plugins extend the agent with new tools, hooks, and capabilities. They follow a standard pattern:

- **Directory**: `gptme-<name>/` (hyphen)
- **Package**: `gptme-<name>` (hyphen, in pyproject.toml)
- **Python module**: `gptme_<name>` (underscore, for imports)
- **Entry point**: `gptme.plugins` group in pyproject.toml
- **Registration**: Export a `tool` (ToolSpec) or hooks
- **Requirements**: Python >=3.10, gptme >=0.27.0, hatchling build

Install via gptme.toml:
```toml
[plugins]
paths = ["path/to/gptme-contrib/plugins"]
enabled = ["gptme_attention_tracker"]
```

Source: `/home/skogix/claude/projects/gptme-contrib/plugins/`

## Plugin Summary Table

| Plugin | Purpose | Claude Code Relevant? |
|--------|---------|----------------------|
| gptme-ace | Agentic Context Engineering — hybrid retrieval, semantic dedup, context curation | Yes — context optimization patterns |
| gptme-attention-tracker | HOT/WARM/COLD tiered context management with attention decay | Yes — token reduction strategies |
| gptme-claude-code | Bridge gptme to Claude Code CLI as subagent | **YES — direct integration** |
| gptme-consortium | Multi-model consensus querying with arbiter synthesis | Moderate — architectural decisions |
| gptme-gptodo | Coordinator-mode task delegation and agent management | **YES — gptodo integration** |
| gptme-gupp | Work persistence across session boundaries via hooks | Yes — session continuity pattern |
| gptme-hooks-examples | Educational hook system examples | Reference only |
| gptme-imagen | Multi-provider image generation (Gemini, DALL-E) | No |
| gptme-lsp | Language Server Protocol integration for code intelligence | Moderate — diagnostics/navigation |
| gptme-ralph | Iterative execution with context reset (Ralph Loop) | Yes — plan execution pattern |
| gptme-retrieval | Auto context retrieval via STEP_PRE hook | Yes — RAG/search integration |
| gptme-warpgrep | AI-powered semantic code search via Morph API | Moderate — code search |
| gptme-wrapped | Usage analytics dashboard (Spotify Wrapped style) | No |

---

## Detailed Plugin Descriptions

### gptme-claude-code

**Source**: `plugins/gptme-claude-code/src/gptme_claude_code/tools/claude_code.py` (~499 lines)

**Purpose**: Bridge that spawns Claude Code CLI (`claude -p`) as focused subagents from within gptme IPython sessions. Each function type constructs specific prompt instructions for the Claude CLI.

**Prerequisites**: Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`), Anthropic API key configured.

#### Architecture

```
gptme IPython session
  └─ ToolSpec "claude_code" (6 functions)
       ├─ analyze/ask/fix/implement → subprocess.run(["claude", "-p", prompt])
       └─ check_session/kill_session → tmux session management
```

**ClaudeCodeResult dataclass**:
```python
@dataclass
class ClaudeCodeResult:
    prompt: str
    output: str
    exit_code: int
    duration_seconds: float
    task_type: str
    session_id: str | None = None  # For background tasks
```

#### Six Functions

| Function | Purpose | Default Timeout | Key Feature |
|----------|---------|----------------|-------------|
| `analyze(prompt, workspace, timeout, background)` | Code reviews, security audits, test coverage | 600s | Warns on sync >240s, raises >=300s (prompt cache protection) |
| `ask(question, workspace, timeout, background)` | Codebase Q&A | 300s | Wraps question with "clear, concise answer with file/line refs" |
| `fix(issue, workspace, timeout, background, auto_commit)` | Lint errors, type errors, build failures | 600s | `auto_commit=False` by default — adds "Do NOT commit" instruction |
| `implement(feature, workspace, timeout, background, use_worktree, branch_name)` | New features, refactoring | 900s | `use_worktree=True` creates git worktree on `feature/{uuid}` branch |
| `check_session(session_id)` | Monitor background task | — | Uses tmux `capture-pane` |
| `kill_session(session_id)` | Cancel background task | — | Uses tmux `kill-session` |

#### Background Task System

Long-running tasks use tmux sessions:
```python
result = analyze("security audit of auth module", background=True, timeout=1800)
# Returns: "Background analysis task started in session: claude_code_a1b2c3d4"
```

- Session ID format: `claude_code_{uuid.uuid4().hex[:8]}`
- Command: `cd {workspace} && timeout {timeout} claude -p {prompt}`

#### Design Decisions

- **Subprocess spawning**: Direct `subprocess.run()` to `claude` CLI with `-p` flag
- **Workspace isolation**: All commands run in specified directory (default: cwd)
- **Prompt engineering**: Each function type adds specific instruction text
- **Guard rails**: Long sync timeout protection for Claude Code's prompt cache
- **Worktree support**: `implement()` can auto-create git worktrees for isolation
- **Cost model**: $200/mo Claude Code subscription makes parallel analysis cheaper than direct API

#### When to Use Claude Code vs gptme Tools

| Use Claude Code | Use gptme |
|----------------|-----------|
| Single-purpose tasks | Multi-step workflows |
| Fresh context needed | Full context history |
| Parallel work | Interactive debugging |
| Cost-effective analysis | File modifications with review |

---

### gptme-gptodo

**Source**: `plugins/gptme-gptodo/src/gptme_gptodo/tools/gptodo_tool.py` (~330 lines)

**Purpose**: Enables **coordinator-only agent mode** where the top-level agent acts as a coordinator that delegates all work to specialized subagents via gptodo. The coordinator cannot execute shell commands or modify code directly — it only uses `gptodo` + `save` tools.

**Prerequisites**: `gptodo` CLI in PATH, or gptme-contrib with `uv` available.

#### Architecture

```
gptme coordinator session (restricted tools)
  └─ ToolSpec "gptodo" (6 functions)
       ├─ delegate() → gptodo spawn/run → new agent session
       ├─ check_agent/list_agents → gptodo status/agents
       └─ list_tasks/task_status/add_task → gptodo list/status/add
```

**CLI discovery**: `_check_gptodo_available()` checks PATH first, then falls back to `gptme-contrib/packages/gptodo` via `uv run`.

#### Six Functions

| Function | Purpose | CLI Command |
|----------|---------|-------------|
| `delegate(prompt, task_id, backend, agent_type, timeout, background)` | Spawn subagent for work | `gptodo spawn` (bg) / `gptodo run` (fg) |
| `check_agent(session_id)` | Monitor delegated agent | `gptodo status <session_id>` |
| `list_agents()` | View active/recent sessions | `gptodo agents --json` |
| `list_tasks(state)` | Query task list | `gptodo list [--active-only]` |
| `task_status(compact)` | Overview of all tasks | `gptodo status [--compact]` |
| `add_task(title, description, priority, task_type)` | Create new task | `gptodo add <title> [opts]` |

#### delegate() Parameters

| Param | Default | Options |
|-------|---------|---------|
| `backend` | `"gptme"` | `"gptme"`, `"claude"` |
| `agent_type` | `"execute"` | `"execute"`, `"plan"`, `"explore"`, `"general"` |
| `timeout` | 600 | seconds |
| `background` | True | True=async, False=wait |

#### Coordinator Workflow

```python
task_status()  # Check what needs doing
s1 = delegate("Fix the failing test in tests/test_auth.py by updating the mock setup")
s2 = delegate("Add type hints to src/auth/handler.py", agent_type="execute")
check_agent("agent_abc123")  # Check progress
list_agents()  # Overview of all agents
```

**Best practices from plugin docs**:
1. Break complex work into focused subtasks
2. Write clear prompts with file paths and success criteria
3. Use `agent_type="execute"` for code changes, `"explore"` for research
4. Use `background=True` for parallel work, `False` for sequential
5. Check agent status before synthesizing results

---

### gptme-ace

**Source**: `plugins/gptme-ace/src/gptme_ace/`

**Purpose**: Agentic Context Engineering — optimizes gptme's lesson system with hybrid retrieval, semantic deduplication, and a Generator-Reflector-Curator-Applier pipeline.

**Key features**:
- **Hybrid retrieval**: keyword (25%) + semantic (40%) + effectiveness (25%) + recency (10%) scoring
- **Semantic dedup**: Embedding-based duplicate detection
- **GRCA pipeline**: Generator extracts insights from sessions → Reflector identifies patterns → Curator refines → Applier updates
- **Drop-in replacement** for gptme's built-in LessonMatcher

**CLI tools**: `python -m gptme_ace.generator`, `.reflector`, `.reviewer`, `.curator`, `.metrics`, `ace-viz`

**Dependencies**: pydantic, numpy, pyyaml, click; optional: sentence-transformers, faiss-cpu, anthropic

**Research basis**: Stanford/SambaNova/UC Berkeley ACE framework (Oct 2025)

---

### gptme-attention-tracker

**Source**: `plugins/gptme-attention-tracker/src/gptme_attention_tracker/`

**Purpose**: Dynamic context management via HOT/WARM/COLD tier system with attention decay.

**Key features**:
- **Three tiers**: HOT (always include), WARM (include if space), COLD (exclude)
- **Attention decay**: Files move to lower tiers without interaction
- **Keyword activation**: Files promoted to HOT when matching keywords appear
- **Co-activation tracking**: Identifies frequently co-occurring files
- **Pinning**: Critical files never fall below WARM
- **Token savings**: 64-95% reduction (full files → headers only)

**Functions**: `register_file()`, `process_turn()`, `get_tiers()`, `get_context_recommendation()`, `record_turn()`, `query_file()`, `query_coactivation()`, `find_underutilized()`

**State**: `.gptme/attention_state.json`, `.gptme/attention_history.jsonl`

---

### gptme-consortium

**Source**: `plugins/gptme-consortium/src/gptme_consortium/`

**Purpose**: Multi-model consensus — queries multiple LLMs in parallel, synthesizes with arbiter model.

**Key features**:
- **Default ensemble**: Claude Sonnet 4.5, GPT-5.1, Gemini 3 Pro, Grok 4
- **Arbiter**: Claude Sonnet 4.5 synthesizes consensus
- **Confidence scoring**: 0-1 agreement score
- **Robust JSON parsing**: Handles markdown blocks, embedded JSON

**Function**: `query_consortium(question, models, arbiter, confidence_threshold)`

**Use cases**: Architectural decisions, code review, quality validation

---

### gptme-gupp

**Source**: `plugins/gptme-gupp/src/gptme_gupp/`

**Purpose**: Work persistence across sessions via hook-based tracking. GUPP = "Gastown Universal Propulsion Principle" — "If there is work on your hook, YOU MUST RUN IT."

**Functions**: `hook_start(task_id, context, next_action)`, `hook_update()`, `hook_list()`, `hook_complete()`, `hook_status()`, `hook_abandon(task_id, reason)`

**Storage**: `state/hooks/` (JSON files), `archive/` for abandoned hooks

---

### gptme-hooks-examples

**Source**: `plugins/gptme-hooks-examples/src/gptme_example_hooks/`

**Purpose**: Educational plugin demonstrating gptme's hook system with type-safe, priority-based hooks.

**Hook types**: SESSION_START, TOOL_PRE_EXECUTE, MESSAGE_POST_PROCESS, MESSAGE_PRE_PROCESS, MESSAGE_TRANSFORM, TOOL_POST_EXECUTE, TOOL_TRANSFORM, FILE_PRE_SAVE, FILE_POST_SAVE, FILE_PRE_PATCH, FILE_POST_PATCH, SESSION_END, GENERATION_PRE, GENERATION_POST, GENERATION_INTERRUPT, LOOP_CONTINUE

**Features**: Priority ordering, StopPropagation support

---

### gptme-imagen

**Source**: `plugins/gptme-imagen/src/gptme_imagen/`

**Purpose**: Multi-provider image generation with unified API.

**Providers**:
| Provider | Model | Cost |
|----------|-------|------|
| Gemini | imagen-3-fast-generate-001 | $0.04/image |
| DALL-E 3 | dall-e-3 | $0.04-$0.08 |
| DALL-E 2 | dall-e-2 | $0.02 |

**Functions**: `generate_image()`, `generate_variation()`, `batch_generate()`, `compare_providers()`, `get_total_cost()`, `get_cost_breakdown()`, `get_generation_history()`

**Features**: 8 style presets, prompt enhancement, cost tracking (SQLite), provider comparison

---

### gptme-lsp

**Source**: `plugins/gptme-lsp/src/gptme_lsp/`

**Purpose**: Language Server Protocol integration for code intelligence.

**Supported servers**: pyright (Python), typescript-language-server (TS/JS), gopls (Go), rust-analyzer (Rust), clangd (C/C++)

**Commands**: `lsp diagnostics`, `lsp definition`, `lsp references`, `lsp hover`, `lsp rename`, `lsp actions`, `lsp symbols`, `lsp format`, `lsp hints`, `lsp callers`, `lsp callees`, `lsp tokens`, `lsp links`, `lsp lens`

**Architecture**: LSPManager with lazy initialization — servers start only when first needed.

---

### gptme-ralph

**Source**: `plugins/gptme-ralph/src/gptme_ralph/`

**Purpose**: Ralph Loop — iterative multi-step execution where context resets between steps. Progress persists in files (markdown checkboxes), not LLM context. Named after the Ralph Wiggum AI coding meme.

**Key features**:
- Markdown plan files with checkbox tracking
- Context reset between steps (only spec + current step in context)
- Supports both `claude` and `gptme` backends
- Background execution via tmux

**Functions**: `run_loop(spec_file, plan_file)`, `create_plan(task_description, output_file)`, `check_loop(session_id)`, `stop_loop(session_id)`

**Parameters**: `backend` ("claude"/"gptme"), `max_iterations` (50), `step_timeout` (600s), `background` (bool)

---

### gptme-retrieval

**Source**: `plugins/gptme-retrieval/src/gptme_retrieval/`

**Purpose**: STEP_PRE hook that auto-retrieves relevant context before each LLM step.

**Backends**:
| Backend | Method | Default |
|---------|--------|---------|
| qmd | Semantic (vsearch), keyword (search), hybrid (query) | Yes |
| gptme-rag | RAG retrieval | Experimental |
| grep | Simple keyword fallback | — |
| Custom | Any command returning JSON | — |

**Config** (gptme.toml):
```toml
[plugin.retrieval]
enabled = true
backend = "qmd"
mode = "vsearch"
max_results = 5
threshold = 0.3
inject_as = "system"
```

---

### gptme-warpgrep

**Source**: `plugins/gptme-warpgrep/src/gptme_warp_grep/`

**Purpose**: AI-powered semantic code search using Morph's warp-grep API. Understands natural language queries, iteratively searches (up to 4 turns).

**Function**: `warp_grep(query, repo_root)`

**Requirements**: ripgrep (`rg`) in PATH, `MORPH_API_KEY` env var

**Dependencies**: gptme, httpx

---

### gptme-wrapped

**Source**: `plugins/gptme-wrapped/src/gptme_wrapped/`

**Purpose**: Usage analytics dashboard (Spotify Wrapped style) — token usage, costs, model preferences, usage patterns.

**Functions**: `wrapped_report()`, `wrapped_stats(year)`, `wrapped_export(format)`

**CLI**: `python -m gptme_wrapped [report|heatmap|stats|export]`

**Features**: Cache hit rates, activity heatmaps, monthly breakdowns, JSON/CSV/HTML export
