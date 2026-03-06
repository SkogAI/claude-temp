# gptme Skills

## Overview

Skills are enhanced lessons in the gptme-contrib monorepo that bundle workflows, scripts, and utilities. Unlike lessons (which are short behavioral patterns auto-included via keyword matching), skills provide complete executable workflows with supporting tools that are explicitly loaded when needed.

**Key differences from lessons:**

| Feature | Lesson | Skill |
|---------|--------|-------|
| Purpose | Behavioral guidance | Executable workflows |
| Content | Patterns, rules, examples | Instructions + bundled scripts |
| Activation | Automatic via keywords | Explicit loading |
| Length | 30-50 lines | Hundreds of lines |
| Scripts | None | Optional bundled utilities |
| Dependencies | None | Python packages if needed |

**Skill structure:** Each skill is a directory under `skills/` containing a `SKILL.md` (with YAML frontmatter: `name`, `description`) and optional supporting files (scripts, templates, resources).

**Source:** `projects/gptme-contrib/skills/`

## Skill Summary Table

| Skill | Purpose | Tags |
|-------|---------|------|
| agent-onboarding | Framework for effective first-interaction user onboarding | onboarding, trust, UX |
| artifact-publishing | Workflow for publishing HTML artifacts to GitHub Pages | publishing, HTML, demos |
| code-review-helper | Systematic code review with bundled analysis utilities | code-review, PRs, quality |
| gptme-wrapped | Conversation analytics (token usage, costs, model preferences) | analytics, tokens, costs |
| plugin-development | Guide to creating gptme plugins (tools, hooks, commands) | plugins, ToolSpec, hooks |
| progressive-disclosure | Restructure large docs into token-efficient directory structures | documentation, context-optimization |
| template-skill | Minimal template for creating new skills | template, scaffolding |

## Detailed Descriptions

### agent-onboarding
**Author:** bob | **Version:** 1.0.0

Comprehensive framework for gptme agent onboarding that builds user trust and establishes productive working relationships. Provides:

- **Pre-onboarding assessment:** Evaluate user's technical comfort (high/medium/low), domain context (professional/academic/creative/personal), and pace preference
- **Adaptive communication templates:** Different templates for high-tech professional, non-technical creative, academic researcher, and personal life management
- **Progressive trust building:** 3 phases (demonstrate reliability -> show competence -> autonomous collaboration)
- **Troubleshooting:** Recovery strategies for AGI expectations, collaboration confusion, style mismatch, trust issues, overwhelm

Has a detailed companion file: `framework-reference.md`.

### artifact-publishing
**Author:** bob | **Version:** 1.0.0 | **Requires:** git, gh

Workflow for publishing HTML demos, visualizations, and interactive content to the web via GitHub Pages. Key features:

- **Publishing targets:** GitHub Pages (recommended), Gist with HTML preview
- **Demo index:** Data-driven demo listing via `_data/demos.yml` with generator provenance (model, harness, orchestration)
- **Best practices:** Self-contained artifacts (single HTML with embedded CSS/JS), responsive design, metadata/attribution, accessibility
- **Communication pattern:** Template for announcing published artifacts with URL and specs

### code-review-helper
**Author:** bob | **Version:** 1.0.0 | **Requires:** git, gh

Systematic code review workflows with automation. Covers:

- **6-dimension analysis:** Correctness, clarity, testing, documentation, performance, security
- **Structured feedback format:** Summary, strengths, issues (critical/important/minor), suggestions, questions, overall assessment
- **Bundled utilities** (`review_helpers.py`):
  - `check_naming_conventions()` - PEP 8 validation
  - `detect_code_smells()` - Anti-pattern detection (magic numbers, long functions, deep nesting)
  - `analyze_complexity()` - Cyclomatic complexity
  - `find_duplicate_code()` - AST-based duplicate detection
  - `check_test_coverage()` - Test-to-code ratio analysis
- **Checklists:** Security-sensitive code, performance-critical code, API changes

### gptme-wrapped
Conversation analytics inspired by Spotify Wrapped. Analyzes gptme conversation history (`~/.local/share/gptme/logs/`) for:

- **Token usage:** Input/output tokens, cache hits
- **Cost tracking:** Spending by model, day, conversation
- **Model preferences:** Most used models, provider breakdown
- **Usage patterns:** Peak hours, conversation lengths
- **Context efficiency:** Average context sizes, compression ratios

Reads `conversation.jsonl` files (messages with metadata including model, token counts, cost) and `config.toml` files.

Plugin integration available via `plugins/wrapped/` (functions: `wrapped_stats`, `wrapped_report`, `wrapped_export`).

### plugin-development
Guide to creating gptme plugins. Covers:

- **Plugin types vs skills/lessons:** Use plugins for custom tools (ToolSpec), runtime hooks, or custom `/command` handlers
- **Plugin structure:** `pyproject.toml` + `src/gptme_my_plugin/` package with tools, hooks, commands subdirs
- **ToolSpec creation:** Define functions, examples, and register as `ToolSpec`
- **Hook system:** 8 hook types (SESSION_START/END, TOOL_PRE/POST_EXECUTE, FILE_PRE/POST_SAVE, GENERATION_PRE/POST)
- **Command registration:** Add custom `/command` handlers with aliases
- **Configuration:** `gptme.toml` `[plugins]` section with paths and enabled list
- **Testing patterns:** `uv run pytest`, `logs_dir` parameter for testability
- **Troubleshooting:** ModuleNotFoundError, import errors, environment mismatch

### progressive-disclosure
Pattern for restructuring large documentation files into slim indexes with on-demand subdirectories. Results in 40-60% reduction in always-included context tokens.

- **When to use:** Files >500 lines or >5k tokens that are always included in context
- **Structure:** Slim index (20% of original, always included) + detail directories (loaded on demand)
- **Implementation:** Analyze -> create directory structure -> write slim index -> create detail files -> update config
- **Anti-patterns:** Too many small files, deep nesting (keep to 2 levels), orphan content, missing quick reference

### template-skill
Minimal template demonstrating basic skill structure. Copy this directory as a starting point for new skills.

- Shows YAML frontmatter format (`name`, `description`)
- Documents optional fields (scripts, dependencies, hooks)
- Explains skill vs lesson distinction
- Provides examples of skills with and without bundled scripts
