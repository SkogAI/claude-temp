# @knowledge/ - knowledge base

<what_is_this>

central repository for documented decisions, learnings, and reusable patterns.
persistent knowledge that accumulates over time.

</what_is_this>

<structure>

@decisions/ # architectural decision records (adrs)
@learnings/ # lessons learned from work
@patterns/ # reusable patterns and approaches
@patterns/style/ # skogai style conventions (routed references)

</structure>

<when_to_use>

- new insight worth preserving -> learnings/
- significant architectural decision made -> decisions/
- pattern identified for reuse -> patterns/

</when_to_use>

<frontmatter>

all entries in learnings/ and decisions/ MUST include frontmatter:

```yaml
---
title: [Descriptive Title]
date: [YYYY-MM-DD]
project: [project-name or "SkogAI"]
tags: [tag1, tag2, tag3]
source: [where this came from — session, PR, experiment, etc.]
status: active
---
```

fields are mandatory. use @templates/knowledge-entry.md as starting point.

</frontmatter>

<file_naming>

use date prefix for chronological sorting:

- decisions/2026-01-19-hq-location.md
- learnings/2026-01-19-claude-routing.md
- patterns/yaml-frontmatter.md (no date - patterns are timeless)

</file_naming>
