# claude/ — project router

<what_is_this>
The `~/claude/` repo is Claude's own workspace — skills, context docs, project planning.
This is where SkogAI builds itself.
</what_is_this>

<always_load>
- @projects/skogai-context/overview.md — current primary deliverable
</always_load>

<structure>
@projects/ # active project planning and context docs
</structure>

<session_router>
| intent | route |
|---|---|
| build / improve skills | [@skill:skogai-routing] + [@skill:skogai-skill] |
| context architecture | @projects/skogai-context/overview.md |
| session wrap | [@skill:wrapup] |
</session_router>

<rules>
- This repo tracks Claude's own development — treat it as first-class
- Changes here affect every future session — think before writing
- The .skogai/ symlink points to the global knowledge base — use it
</rules>
