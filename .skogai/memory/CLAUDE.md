# @memory/ - memory system

<what_is_this>

session state and persistent context. what i'm working on, what decisions have been made.
short-term and medium-term memory for continuity across sessions.

</what_is_this>

<structure>

@context/current.md  # generated — do not edit manually
@decisions.md        # append-only quick decision log

</structure>

<when_to_use>

- quick decision record -> decisions.md (append)
- detailed decision -> knowledge/decisions/ (full adr)
- read current state -> context/current.md (generated from journal + decisions)

</when_to_use>

<workflow>

1. start session: read context/current.md (generated — do not edit manually)
2. during work: append to decisions.md for quick notes
3. end session: add journal entry; current.md regenerates from journal + decisions
4. significant decisions: promote to knowledge/decisions/

</workflow>
