# @plan/ — project planning router

<what_is_this>

planning-with-files workspace. each project gets task_plan.md (phases), findings.md (decisions/architecture), progress.md (session log).

</what_is_this>

<status_overview>

| project | phase | status | next action |
|---------|-------|--------|-------------|
| headquarters | Phase 1 (bootstrap) | in_progress | verify AUR packages on real HW |
| claude-memory | Phase 2 (stabilization) | in_progress | CI/CD, test health, parser TODO |
| gptme-contrib | Phase 2 (hardening) | in_progress | shared lib tests, plugin CI validation |
| argcfile | Phase 2 (validation) | in_progress | test workspace open on real worktree |

</status_overview>

<routing>

| project | task_plan | findings | progress |
|---------|-----------|----------|----------|
| headquarters | @headquarters/task_plan.md | @headquarters/findings.md | @headquarters/progress.md |
| claude-memory | @claude-memory/task_plan.md | @claude-memory/findings.md | @claude-memory/progress.md |
| gptme-contrib | @gptme-contrib/task_plan.md | @gptme-contrib/findings.md | @gptme-contrib/progress.md |
| argcfile | @argcfile/task_plan.md | @argcfile/findings.md | @argcfile/progress.md |

</routing>

<conventions>

- **task_plan.md** — phases, checkboxes, decisions, errors. the "what and when."
- **findings.md** — architecture, technical decisions, research. the "what and why."
- **progress.md** — session logs, test results, reboot check. the "what happened."
- update progress.md at end of each session
- update status_overview in this file when phase changes

</conventions>
