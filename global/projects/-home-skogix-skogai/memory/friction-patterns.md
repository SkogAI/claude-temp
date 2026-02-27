# Friction Patterns & Mitigations

## From Insights Analysis (Feb 2026, 2 sessions analyzed)

### Top Friction Categories

1. **Incorrect Assumptions Without Verification** (most impactful)
   - Made wrong claims about token security, SSH access, symlink direction
   - Mitigation: ALWAYS read configs and run diagnostics before asserting anything

2. **Destructive File Operations**
   - Write broke hard links; deleted config entries without reason
   - Mitigation: Check `ls -la` first; use Edit not Write; never remove entries unprompted

3. **Brute-Force Tool Usage Without Planning**
   - 65 Bash calls, only 8 think calls — too much acting vs reasoning
   - Botched gitignore patterns, symlinks, file operations repeatedly
   - Mitigation: Plan in 2-3 sentences before any multi-step operation

### Stats
- 6 wrong approaches, 3 misunderstood requests, 3 buggy code instances
- 5 dissatisfied moments vs 1 happy moment
- Sessions took ~3h due to constant course-correction

### Suggested Improvements to Try
- **Hooks**: Pre-edit check for symlinks/hardlinks
- **Custom Skills**: `/sync-config` for repeatable config workflows
- **Parallel Sub-Agents**: Audit / plan / validate in parallel for multi-file ops
- **verify_state.sh pattern**: Write validation script upfront, run after each step
