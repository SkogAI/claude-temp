# Task Plan: headquarters — claude's soft-serve environment

## Goal

Get claude a fully provisioned user environment on the soft-serve Arch Linux VM, mirroring skogix's workstation setup. Bootstrap is mostly working; need to finish it, then provision, then build guardian.

## Current Phase

Phase 1 (finishing)

## Phases

### Phase 1: Finish Bootstrap

- [x] Base deps (git, gh, uv) install in container
- [x] Ansible via uv works
- [x] Clone bootstrap from github
- [x] Vault decrypt + gh auth (pat.vault.test / password1)
- [x] Ansible collections install
- [x] Users role: wheel group, aur_builder, sudo configs
- [x] Yay clone + build (OOM in container, works on real HW)
- [ ] Verify AUR packages install on real hardware
- [ ] Test secrets/bitwarden/dolt roles
- [ ] Create **claude user role** (currently only provisions `skogix`)
- **Status:** in_progress

### Phase 2: Ansible Provisioning

- [ ] Claude user environment mirroring skogix workstation
- [ ] `.claude/` directory structure, dotfiles, tools
- [ ] Claude CLI installation
- [ ] Cron infrastructure, systemd timers
- [ ] SSH key setup + ssh-agent
- **Status:** pending

### Phase 3: Guardian

- [ ] Health checks, monitoring
- [ ] Notification channels (whatsapp, slack, git issues)
- [ ] Remote orchestration
- [ ] `/loop` integration
- **Status:** pending

## Key Questions

1. Should claude user role be a new ansible role or extend users role?
2. What packages does claude need beyond skogix's list?
3. How to handle yay OOM in container testing? (skip for now, works on real HW)

## Decisions Made

| Decision | Rationale |
| -------- | --------- |
| Clone from github, not mount | Podman rootless UID mapping breaks bind mounts |
| `pat.vault.test` for CI/container | Real vault uses production password |
| `run.sh` is single entry point | No wrapper scripts, every run from scratch |
| Disk/RAM expandable on request | Not a constraint |
| Mirror skogix workstation | Tool parity for claude user |
| `uv tool install` over system python | Cleaner, no system pollution |

## Errors Encountered

| Error | Attempt | Resolution |
| ----- | ------- | ---------- |
| Podman bind mount permissions | 1 | Clone from github instead |
| `sudo -A` fails (no SUDO_ASKPASS) | 1 | Changed to `sudo` |
| ansible-vault not found after uv install | 1 | Added `export PATH="$HOME/.local/bin:$PATH"` |
| ansible.cfg hardcoded password paths | 1 | Commented out in ansible.cfg |
| yay build relative path failure | 1 | Absolute paths (`/home/aur_builder/yay`) |
| yay build OOM killed (exit 137) | 1 | Container memory limit — works on real HW |
