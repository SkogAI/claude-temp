# gptme-lessons-extras

## Purpose

Lesson management extensions for gptme. Provides tools for creating, validating, analyzing, reviewing, importing, exporting, and evolving lessons. Includes analytics for tracking lesson usage across conversations, similarity detection for deduplication, effectiveness tracking, and workflow automation for lesson generation from failure logs and conversation analysis. This is the largest utility package with 30+ source files covering the full lesson lifecycle.

## CLI Commands

No `[project.scripts]` entry in pyproject.toml. Most modules have `main()` functions designed to be run as scripts or imported:

| Module | CLI / Entry | Description |
|--------|-------------|-------------|
| `workflow.py` | Click group: `create-from-template`, `create-from-failure`, `validate` | Lesson generation workflow tools |
| `analytics.py` | `python -m gptme_lessons_extras.analytics` | Lesson usage analytics — scans conversation logs |
| `validate.py` | Script | Validate lesson files for required sections/format |
| `generate.py` | Script | Generate lessons (template-based) |
| `review.py` | Script | Review and quality-check lessons |
| `export.py` | Script | Export lessons to various formats |
| `sync.py` | Script | Sync lessons across sources |
| `similarity.py` | Script | Find similar/duplicate lessons |
| `discovery.py` | Script | Discover potential new lessons |
| `adopt.py` | Script | Adopt lessons from external sources |
| `evolution.py` | Script | Track lesson evolution over time |
| `metrics.py` | Script | Lesson quality metrics |
| `import.py` | Script | Import lessons from external formats |

Standalone script files (hyphenated names, run directly):
- `analyze-lesson-usage.py` — Analyze lesson usage patterns
- `check-staleness.py` — Check for stale lessons
- `create-pr.py` — Create PRs for lesson changes
- `detect-lesson-patterns.py` — Detect patterns in lessons
- `generate-lesson.py` — Generate new lessons
- `generate-review-prompts.py` — Generate review prompts
- `improve-lesson-keywords.py` — Improve lesson keyword matching

## Python API

### Core Modules

| Module | Key Exports | Description |
|--------|-------------|-------------|
| `workflow.py` | `LessonTemplate`, `create_lesson_from_template()`, `validate_lesson()`, `create_from_failure_log()` | Lesson creation workflow with YAML frontmatter template |
| `analytics.py` | `LessonReference`, `LessonStats`, `find_lesson_files()`, `extract_lesson_references()`, `analyze_conversations()`, `generate_report()` | Scan conversation.jsonl logs for lesson references, generate rich table reports |
| `validate.py` | Validation functions | Check lessons for required sections: Rule, Context, Failure Signals, Anti-pattern, Recommended Pattern, Fix Recipe, Rationale, Verification Checklist, Origin |
| `similarity.py` | Similarity detection | Find duplicate or near-duplicate lessons |
| `effectiveness_tracker.py` | Effectiveness tracking | Track how effective lessons are at preventing issues |
| `evolution.py` | Evolution tracking | Track how lessons change over time |
| `review.py` | Review tools | Quality review and scoring |
| `metrics.py` | Quality metrics | Quantitative lesson quality measurements |
| `discovery.py` | Lesson discovery | Discover potential new lessons from patterns |
| `adopt.py` | Lesson adoption | Import lessons from external sources |
| `export.py` | Export tools | Export lessons to various formats |
| `sync.py` | Sync tools | Synchronize lessons across sources |
| `generate.py` | Generation tools | Generate lessons programmatically |

### Analysis Subpackage

| Module | Description |
|--------|-------------|
| `analysis/__init__.py` | Analysis subpackage init |
| `analysis/conversations.py` | Conversation analysis for lesson extraction |

### Utils Subpackage

| Module | Description |
|--------|-------------|
| `utils/data.py` | Data utilities |
| `utils/evolution.py` | Evolution tracking utilities |
| `utils/formatting.py` | Output formatting helpers |
| `utils/keywords.py` | Keyword extraction and matching |
| `utils/llm.py` | LLM interaction utilities |
| `utils/pareto.py` | Pareto analysis (80/20 rule for lessons) |
| `utils/similarity.py` | Similarity computation utilities |
| `utils/variants.py` | Lesson variant management |

### Lesson File Format

Required YAML frontmatter:
```yaml
---
match:
  keywords: [keyword1, keyword2]
  tools: [tool1, tool2]
---
```

Required markdown sections:
- `# Title`
- `## Rule` — One-sentence imperative constraint
- `## Context` — When this applies
- `## Failure Signals` — How to detect the problem
- `## Anti-pattern` — What not to do (with code snippet)
- `## Recommended Pattern` — What to do (with code snippet)
- `## Fix Recipe` — Step-by-step fix
- `## Rationale` — Why this matters
- `## Verification Checklist` — How to verify the fix
- `## Origin` — Where/when learned

Optional: `## Exceptions`, `## Automation Hooks`, `## Related`

## Configuration

| Config | Description |
|--------|-------------|
| Lessons directory | Auto-detected from git root: `<repo>/lessons/` |
| gptme logs | `~/.local/share/gptme/logs/` — conversation.jsonl files scanned for analytics |
| Report output | `<repo>/knowledge/meta/lesson-usage-report.md` |

## Dependencies

**Depends on:** PyYAML, click, python-frontmatter, rich, gptme

**Depended on by:** None directly — standalone tooling for lesson management.

## Claude Code Integration

- Lesson validation (`validate_lesson()`) could be used as a pre-commit hook for lesson files
- Analytics could feed into Claude Code context to show which lessons are most/least effective
- The lesson template format is compatible with gptme's lesson matching system — lessons written with these tools are automatically picked up by gptme agents
- `create-from-failure` workflow could be integrated into post-mortem claude-code sessions

## Key Source Files

| File | Purpose |
|------|---------|
| `src/gptme_lessons_extras/workflow.py` | Core workflow: create from template, create from failure log, validate |
| `src/gptme_lessons_extras/analytics.py` | Conversation log scanning, usage tracking, rich report generation |
| `src/gptme_lessons_extras/validate.py` | Lesson validation against required format |
| `src/gptme_lessons_extras/similarity.py` | Duplicate/near-duplicate lesson detection |
| `src/gptme_lessons_extras/effectiveness_tracker.py` | Track lesson effectiveness |
| `src/gptme_lessons_extras/evolution.py` | Track lesson changes over time |
| `src/gptme_lessons_extras/review.py` | Lesson quality review tools |
| `src/gptme_lessons_extras/discovery.py` | Discover potential new lessons |
| `src/gptme_lessons_extras/adopt.py` | Adopt lessons from external sources |
| `src/gptme_lessons_extras/export.py` | Export lessons to various formats |
| `src/gptme_lessons_extras/sync.py` | Sync lessons across sources |
| `src/gptme_lessons_extras/utils/` | Utility subpackage: keywords, similarity, formatting, LLM, pareto, variants |
| `src/gptme_lessons_extras/analysis/` | Conversation analysis subpackage |
| `tests/test_effectiveness_tracker.py` | Tests for effectiveness tracking |

## Legacy: packages/lessons/

The `packages/lessons/` directory has identical `pyproject.toml` (same name, deps, build config). It contains the same source under `src/gptme_lessons_extras/`. The modern `packages/gptme-lessons-extras/` is the canonical location.

## Legacy: packages/run_loops/

The `packages/run_loops/` directory contained the legacy version of `gptme-runloops` (Python-based run loop framework for autonomous AI agent operation). It has been superseded by `packages/gptme-runloops/`. Key differences:
- Same package name (`gptme-runloops`) and CLI entry points (`gptme-runloops`, `run-loops`)
- Deps: click, pyyaml, tomli
- The modern `gptme-runloops` package is the canonical location
