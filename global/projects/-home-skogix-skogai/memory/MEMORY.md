# Memory Index

## User Profile
- Expert-level sysadmin who knows exactly what they want
- Works primarily with shell, config files, infrastructure (SSH, cloudflared, bare git repos, symlinks)
- Will catch mistakes fast — don't waste their time with wrong assumptions
- See [user-preferences.md](user-preferences.md) for detailed patterns

## Key Rules (also in ~/.claude/CLAUDE.md)
- Think first, act second — plan before executing
- Verify before asserting — never claim something without evidence
- Use Edit over Write on existing files (preserves hard links)
- Check symlink direction with `ls -la` before creating
- Verify .gitignore patterns with `git check-ignore -v`

## Known Friction Points
- See [friction-patterns.md](friction-patterns.md) for detailed analysis
