# Task Plan: gptme-contrib — autonomous agent infrastructure monorepo

## Goal

Mature the monorepo from 0.1.0 beta across all packages toward v1.0 stability, with complete test coverage, CI validation, and Claude Code integration.

## Current Phase

Phase 2 (hardening)

## Phases

### Phase 1: Foundation (complete)

- [x] 12 packages structured and installable
- [x] 13 plugins with gptme integration
- [x] 7 skills (prompt templates)
- [x] Dynamic CI test discovery (packages + plugins)
- [x] Click CLI standardization
- [x] Pre-commit hooks for lesson validation
- [x] Dashboard with auto-deploy to gh-pages
- **Status:** complete

### Phase 2: Hardening

- [ ] Fix 5 plugins with untested CI suites (ace, attention-tracker, claude-code, lsp, warpgrep)
- [ ] Add tests for gptme-contrib-lib (shared foundation, currently 0 tests)
- [ ] Fix gptme-contrib-lib mypy exclusion (hyphenated name issue)
- [ ] Resolve 16 TODO/FIXME annotations in Python code
- [ ] Validate all package tests pass in CI
- **Status:** in_progress

### Phase 3: Claude Code Integration

- [ ] gptme-claude-code plugin test coverage
- [ ] gptme-gptodo plugin (delegate to CC subagents) validation
- [ ] Team mode coordinator tool restriction (known limitation)
- [ ] Document nesting pattern (strip CLAUDECODE env vars)
- **Status:** pending

### Phase 4: v1.0 Release Prep

- [ ] Version bump strategy across packages
- [ ] Release notes / changelog per package
- [ ] PyPI publication workflow
- [ ] README / docs accuracy audit
- **Status:** pending

## Key Questions

1. Should gptme-contrib-lib be renamed to fix the mypy hyphen issue?
2. What's the v1.0 criteria per package?
3. Should the 3 untested plugins (retrieval, warpgrep, wrapped) be deprecated or tested?

## Decisions Made

| Decision | Rationale |
| -------- | --------- |
| All CLIs use Click (not argparse) | Consistency, better UX |
| Dynamic CI test discovery | Only test affected packages on PRs |
| uv workspace for monorepo | Fast, lockfile-based, Python standard |
| 0.1.0 across all packages | Stable beta — production use but no v1.0 guarantees |
| Dashboard auto-deploy to gh-pages | Visibility into package/plugin/lesson status |

## Errors Encountered

| Error | Attempt | Resolution |
| ----- | ------- | ---------- |
| gptme-contrib-lib mypy fail | 1 | Excluded from mypy (not fixed) |
| 5 plugin test suites never ran in CI | 1 | Dynamic discovery added, validation pending |
