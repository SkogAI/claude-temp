# User Preferences & Workflow

## Communication Style
- Expects precision — no hand-waving or confident-but-wrong claims
- Prefers verification over assumptions
- Will correct mistakes in real-time; don't repeat the same mistake twice

## Preferred Tools & Approaches
- rsync over cp (preserves permissions/attributes)
- Edit tool over Write tool on existing files (preserves hard links)
- Bare git repos for dotfile management
- Symlinks: `ln -s <real-file> <link-name>` — always verify direction

## Workflow Preferences
- Outline plan before executing multi-step operations
- Checkpoint after file operations (ls -la, git status)
- Front-load state discovery — explore before modifying
- Use task agents to audit state before making changes on complex tasks

## Things NOT to Do
- Don't make security/config claims without reading the actual files first
- Don't delete existing config entries without explicit approval
- Don't use Write on files that might be symlinks or hard links
- Don't guess at gitignore patterns — test them
- Don't brute-force through commands without thinking
