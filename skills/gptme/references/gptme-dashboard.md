# gptme-dashboard

## Purpose

Static dashboard generator for gptme workspaces. Scans a workspace directory for lessons, plugins, packages, and skills, then generates a static HTML site (suitable for gh-pages) and/or a JSON data dump. Automatically detects and includes content from git submodules with gptme-like structure. Renders markdown lesson/skill detail pages with Jinja2 templates. Designed to work with any gptme workspace (gptme-contrib, bob, alice, etc.).

## CLI Commands

Entry point: `gptme-dashboard` (installed via `[project.scripts]`)

| Command | Options | Description |
|---------|---------|-------------|
| `gptme-dashboard` | `--workspace PATH` `--output PATH` `--templates PATH` `--json` | Generate dashboard. Default workspace: `.`, default output: `_site/` |

Options:
- `--workspace PATH` — Path to gptme workspace (default: current directory)
- `--output PATH` — Output directory (default: `_site`). Generates both `index.html` and `data.json`
- `--templates PATH` — Custom Jinja2 template directory (default: built-in templates)
- `--json` — Print JSON to stdout. Without `--output`, skips HTML generation entirely (for piping to `jq`, CI artifacts)

## Python API

### generate.py — Core Generator

| Function | Description |
|----------|-------------|
| `collect_workspace_data(workspace)` | Main scanner: returns dict with all workspace data (lessons, plugins, packages, skills, guidance, stats, submodules, sources) |
| `generate(workspace, output, template_dir)` | Generate full static HTML site with detail pages for each lesson and skill |
| `generate_json(workspace, output)` | Generate `data.json` dump (excludes large fields like body/all_keywords) |
| `scan_lessons(workspace, source)` | Scan `lessons/` for `.md` files, parse frontmatter, extract titles/categories/keywords |
| `scan_plugins(workspace, source, enabled_plugins)` | Scan `plugins/` directories, read READMEs, check enabled status from gptme.toml |
| `scan_packages(workspace, source)` | Scan `packages/` for Python packages, read pyproject.toml for description/version |
| `scan_skills(workspace, source)` | Scan `skills/` for `SKILL.md` files, parse frontmatter |
| `detect_submodules(workspace)` | Read `.gitmodules`, find submodules with gptme-like structure (lessons/, skills/, packages/, plugins/) |
| `read_workspace_config(workspace)` | Read `gptme.toml` for agent name, enabled plugins via gptme's config module |
| `detect_github_url(workspace)` | Get GitHub repo URL from git remote (SSH or HTTPS) |
| `parse_frontmatter(path)` | Parse YAML frontmatter from markdown files |
| `render_markdown_to_html(md_text)` | Render markdown to HTML (fenced_code, tables, codehilite extensions) |
| `github_blob_url(gh_repo_url, path, prefix)` | Build GitHub blob URL for file links |
| `github_tree_url(gh_repo_url, path, prefix)` | Build GitHub tree URL for directory links |

### cli.py — Click CLI

| Function | Description |
|----------|-------------|
| `main()` | Click command with workspace/output/templates/json options |

### Data Structure (from `collect_workspace_data`)

```python
{
    "workspace_name": str,        # From gptme.toml agent name or directory name
    "gh_repo_url": str,           # GitHub repo URL for source links
    "lessons": [dict],            # title, category, status, keywords, body, path, page_url, gh_url
    "plugins": [dict],            # name, description, path, enabled, gh_url
    "packages": [dict],           # name, description, version, path, gh_url
    "skills": [dict],             # name, description, body, path, page_url, gh_url
    "guidance": [dict],           # Unified lessons + skills, sorted, with kind field
    "stats": dict,                # total_lessons, total_plugins, total_packages, total_skills
    "lesson_categories": dict,    # category -> count
    "submodules": [str],          # Detected submodule names
    "sources": [str],             # Unique source names for UI filtering
}
```

## Configuration

| Config | Description |
|--------|-------------|
| `gptme.toml` | Read via gptme's `get_project_config()`. Used for `agent.name` and `plugins.enabled` |
| `.gitmodules` | Parsed to detect submodules with gptme-like structure |
| Template directory | Built-in at `src/gptme_dashboard/templates/`. Customizable via `--templates` |

## Dependencies

**Depends on:** click, gptme (>=0.21), jinja2, markdown, pygments, pyyaml

**Depended on by:** None — standalone generator tool.

## Claude Code Integration

- The JSON data dump (`data.json`) could be used as context for Claude Code sessions to understand workspace structure
- Could be run as a post-commit hook to keep dashboard updated
- The `--json` stdout mode is pipe-friendly for integration with other tools
- Useful for auditing what lessons/plugins/skills exist across a workspace and its submodules

## Key Source Files

| File | Purpose |
|------|---------|
| `src/gptme_dashboard/cli.py` | Click CLI entry point |
| `src/gptme_dashboard/generate.py` | Core scanner/generator: workspace scanning, HTML/JSON generation, submodule detection |
| `src/gptme_dashboard/templates/` | Jinja2 HTML templates (index.html, lesson.html, skill.html) |
| `tests/test_generate.py` | Tests for the generator |
