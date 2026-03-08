# headquarters — claude's home base on soft-serve

<what_is_this>

provisioning and guardian infrastructure for claude's dedicated environment on the `soft-serve` Arch Linux VM (10.10.0.25). coordinates bootstrap, ansible provisioning, container management, monitoring, and orchestration.

</what_is_this>

<target>

| property | value |
|----------|-------|
| host | `soft-serve` / `10.10.0.25` |
| os | Arch Linux (rolling) |
| ram | 2GB (expandable on request) |
| disk | 9GB total (expandable on request) |
| python | 3.14 (system) |
| claude user | **does not exist yet** |

</target>

<submodules>

### bootstrap/ — `SkogAI/bootstrap`
one-liner arch linux provisioning. clones from github, runs `bootstrap.sh`.

**flow**: `bootstrap.sh` → `sudo pacman -S github-cli uv git` → `uv tool install ansible-core` → `ansible-vault view pat.vault.test` → `gh auth login` → `ansible-galaxy collection install` → `ansible-playbook playbooks/bootstrap.yml`

**playbook roles** (in order):
1. **users** — wheel group, aur_builder user, yay AUR helper, pacman packages
2. **packages** — full workstation package list (53 pacman + 20 AUR packages)
3. **secrets** — clones SSH keys from github.com/skogai/secrets
4. **bitwarden** — bitwarden integration
5. **dolt** — dolt database + systemd service

**testing**: `pat.vault.test` encrypted with `password1` (via `pat.password.example`) for container/CI use. real `pat.vault` uses production vault password.

### container/ — `SkogAI/container`
arch linux docker dev container + podman service management (21 service scripts).

</submodules>

<goals>

## phase 1: bootstrap (in progress)
- clone `SkogAI/bootstrap`, run `bootstrap.sh` — **working through gh auth + ansible playbook**
- current blocker: yay build gets OOM killed in container
- extend with claude user role (currently only provisions `skogix`)

## phase 2: ansible provisioning
- claude user environment mirroring skogix workstation
- `.claude/` directory structure, dotfiles, tools
- cron infrastructure, systemd timers

## phase 3: guardian
- health checks, monitoring, `/loop` integration
- notification channels: whatsapp, slack, git issues
- remote orchestration

</goals>

<decisions>

- **disk/hardware**: expandable on request, not a constraint
- **bootstrap method**: `git clone` bootstrap from github, run `bootstrap.sh`
- **tool parity**: claude's environment mirrors skogix workstation
- **SSH auth**: github ssh keys + ssh-agent
- **testing**: bare arch container simulates fresh archinstall VM
- **vault for testing**: `pat.vault.test` + `pat.password.example` (`password1`)
- **ansible.cfg**: password file paths commented out (not needed with passwordless sudo)

</decisions>

<development>

### files
| file | purpose |
|------|---------|
| Dockerfile | bare arch + base-devel + sudo + openssh + git + python + skogix user |
| docker-compose.yml | runs `soft-serve` container with bootstrap/ mounted |
| run.sh | clean teardown → build → start → clone bootstrap from github → run bootstrap.sh |
| test-bootstrap.sh | validates bootstrap steps (container, deps, ansible, clone, gh auth) |

### bootstrap status
| step | status |
|------|--------|
| base deps (git, gh, uv) | working |
| ansible via uv | working |
| clone bootstrap from github | working |
| vault decrypt + gh auth | working |
| ansible collections | working |
| playbook: users role (groups, aur_builder, sudo) | working |
| playbook: yay build | OOM killed in container |
| playbook: packages | not reached |
| playbook: secrets/bitwarden/dolt | not tested |

</development>

<routing>

| need | go to |
|------|-------|
| open questions | QUESTIONS.md |
| bootstrap repo | bootstrap/ (submodule: SkogAI/bootstrap) |
| container tooling | container/ (submodule: SkogAI/container) |
| ansible roles | bootstrap/roles/ |
| package lists | bootstrap/vars/packages.yml |
| run full test | run.sh |
| verify results | test-bootstrap.sh |

</routing>

<environment>

- `docker` is podman on this system — stale pods/networks need cleanup between runs
- podman rootless UID mapping breaks file permissions on bind mounts — clone from github instead
- `run.sh` is the single entry point — don't create wrapper scripts
- always push bootstrap changes before running `run.sh` (container clones from github)
- prefer `uv tool install` over system python/pacman for tooling
- every run is from scratch — no cached state, no shortcuts

</environment>

<conventions>

follows @.skogai/knowledge/patterns/style/CLAUDE.md conventions.
commits: `{type}(headquarters): {description}`

</conventions>
