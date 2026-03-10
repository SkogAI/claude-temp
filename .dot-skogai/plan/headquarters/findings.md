# Findings & Decisions

## Architecture

- **Target**: soft-serve VM (10.10.0.25), Arch Linux, 2GB RAM (expandable), 9GB disk (expandable)
- **Bootstrap repo**: SkogAI/bootstrap — cloned fresh each run from github
- **Container repo**: SkogAI/container — arch linux docker dev container + podman service management
- **Testing**: bare arch container simulates fresh archinstall VM

## Bootstrap Flow (working)

```
bootstrap.sh → sudo pacman -S github-cli uv git
             → uv tool install ansible-core + PATH export
             → ansible-vault view pat.vault.test (password1) | gh auth login
             → gh auth setup-git + gh auth status
             → ansible-galaxy collection install -r .requirements.yml
             → ansible-playbook playbooks/bootstrap.yml
```

## Playbook Roles (in order)

1. **users** — wheel group, aur_builder user, yay AUR helper, pacman packages
2. **packages** — full workstation package list (53 pacman + 20 AUR packages)
3. **secrets** — clones SSH keys from github.com/skogai/secrets
4. **bitwarden** — bitwarden integration
5. **dolt** — dolt database + systemd service

## Container Quirks

- `docker` is podman on this system — stale pods/networks need cleanup between runs
- Podman rootless UID mapping breaks file permissions on bind mounts
- yay build OOM killed with container memory limits (works on real hardware)
- Python must be in container (ansible needs it on target)

## Key Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Bare arch + base-devel + sudo + openssh + git + python + skogix user |
| `docker-compose.yml` | Runs soft-serve container |
| `run.sh` | Single entry point: cleanup → build → start → clone → bootstrap |
| `test-bootstrap.sh` | Validates bootstrap steps in container |
| `bootstrap/bootstrap.sh` | The actual bootstrap script |
| `bootstrap/roles/` | Ansible roles |
| `bootstrap/vars/packages.yml` | Package lists |

## User Preferences (from QUESTIONS.md answers)

- Hardware is expandable on request, not a constraint
- ~20 existing services on soft-serve — not in scope currently
- Claude user auth: github SSH keys + ssh-agent (not in focus yet)
- Notification channels: everything exists but nothing integrated yet
- Claude CLI: will be part of bootstrap/ansible setup
- Tools: mirror skogix workstation
- Secrets: ssh-agent for now, rest not in scope
- Monitoring/guardian: "literally hundreds of millions worth of tokens to explain" — defer
