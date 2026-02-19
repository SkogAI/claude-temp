---
name: wrap-up
description: use when user says "wrap up", "close session", "end session",
  "wrap things up", "close out this task", or invokes /wrap-up — runs
  end-of-session checklist for shipping, memory, and self-improvement
---

# session wrap-up

run four phases in order. each phase is conversational and inline — no
separate documents. all phases auto-apply without asking; present a
consolidated report at the end.

## phase 1: ship it

**commit:**

1. run `git status` in each repo directory that was touched during the session
2. if uncommitted changes exist, auto-commit to main with a descriptive message
3. push to remote

**file placement check:** 4. if any files were created or saved during this session:

- verify they follow your naming convention
- auto-fix naming violations (rename the file)
- verify they're in the correct subfolder per your project structure
- auto-move misplaced files to their correct location

5. if any document-type files (.md, .docx, .pdf, .xlsx, .pptx) were created
   at the workspace root or in code directories, move them to the docs folder
   if they belong there

**deploy:** 6. check if the project has a deploy skill or script 7. if one exists, run it 8. if not, skip deployment entirely — do not ask about manual deployment

**task cleanup:** 9. check the task list for in-progress or stale items 10. mark completed tasks as done, flag orphaned ones

## phase 2: remember it

review what was learned during the session. decide where each piece of
knowledge belongs in the memory hierarchy:

**memory placement guide:**

- **auto memory** (claude writes for itself) — debugging insights, patterns
  discovered during the session, project quirks. tell claude to save these:
  "remember that..." or "save to memory that..."
- **claude.md** (instructions for claude) — permanent project rules,
  conventions, commands, architecture decisions that should guide all future
  sessions
- **`.claude/rules/`** (modular project rules) — topic-specific instructions
  that apply to certain file types or areas. use `paths:` frontmatter to scope
  rules to relevant files (e.g., testing rules scoped to `tests/**`)
- **`claude.local.md`** (private per-project notes) — personal wip context,
  local urls, sandbox credentials, current focus areas that shouldn't be
  committed
- **`@import` references** — when a claude.md would benefit from referencing
  another file rather than duplicating its content

**decision framework:**

- is it a permanent project convention? → claude.md or `.claude/rules/`
- is it scoped to specific file types? → `.claude/rules/` with `paths:`
  frontmatter
- is it a pattern or insight claude discovered? → auto memory
- is it personal/ephemeral context? → `claude.local.md`
- is it duplicating content from another file? → use `@import` instead

note anything important in the appropriate location.

## phase 3: review & apply

analyze the conversation for self-improvement findings. if the session was
short or routine with nothing notable, say "nothing to improve" and proceed
to phase 4.

**auto-apply all actionable findings immediately** — do not ask for approval
on each one. apply the changes, commit them, then present a summary of what
was done.

**finding categories:**

- **skill gap** — things claude struggled with, got wrong, or needed multiple
  attempts
- **friction** — repeated manual steps, things user had to ask for explicitly
  that should have been automatic
- **knowledge** — facts about projects, preferences, or setup that claude
  didn't know but should have
- **automation** — repetitive patterns that could become skills, hooks, or
  scripts

**action types:**

- **claude.md** — edit the relevant project or global claude.md
- **rules** — create or update a `.claude/rules/` file
- **auto memory** — save an insight for future sessions
- **skill / hook** — document a new skill or hook spec for implementation
- **claude.local.md** — create or update per-project local memory

present a summary after applying, in two sections — applied items first,
then no-action items:

findings (applied):

1. ✅ skill gap: cost estimates were wrong multiple times
   → [claude.md] added token counting reference table

2. ✅ knowledge: worker crashes on 429/400 instead of retrying
   → [rules] added error-handling rules for worker

3. ✅ automation: checking service health after deploy is manual
   → [skill] created post-deploy health check skill spec

---

no action needed:

4. knowledge: discovered x works this way
   already documented in claude.md

## phase 4: publish it

after all other phases are complete, review the full conversation for material
that could be published. look for:

- interesting technical solutions or debugging stories
- community-relevant announcements or updates
- educational content (how-tos, tips, lessons learned)
- project milestones or feature launches

**if publishable material exists:**

draft the article(s) for the appropriate platform and save to a drafts folder.
present suggestions with the draft:

all wrap-up steps complete. i also found potential content to publish:

1. "title of post" — 1-2 sentence description of the content angle.
   platform: reddit
   draft saved to: drafts/title-of-post/reddit.md

wait for the user to respond. if they approve, post or prepare per platform.
if they decline, the drafts remain for later.

**if no publishable material exists:**

say "nothing worth publishing from this session" and you're done.

**scheduling considerations:**

- if the session produced multiple publishable items, do not post them all
  at once
- space posts at least a few hours apart per platform
- if multiple posts are needed, post the most time-sensitive one now and
  present a schedule for the rest
