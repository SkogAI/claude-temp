# headquarters — claude's home base on soft-serve

<what_is_this>

provisioning and guardian infrastructure for claude's dedicated environment on the `soft-serve` Arch Linux VM (10.10.0.25). bootstrap scripts, ansible playbooks, monitoring, and orchestration tooling.

</what_is_this>

<target>

| property | value |
|----------|-------|
| host | `soft-serve` / `10.10.0.25` |
| os | Arch Linux (rolling) |
| kernel | 6.18.2-arch2-1 |
| ram | 2GB |
| disk | 9GB total (1.6GB free as of 2026-03-08) |
| python | 3.13 |
| claude cli | exists at `/home/skogix/.local/bin/claude` |
| claude user | **does not exist yet** |
| ansible | not installed |
| docker/podman | not installed |

</target>

<goals>

## phase 1: bootstrap
- create `claude` user with proper groups and SSH access
- install ansible (locally or on soft-serve)
- base system packages

## phase 2: ansible provisioning
- playbook for claude user environment
- `.claude/` directory structure, dotfiles, tools
- claude CLI installed under `/home/claude/`
- cron infrastructure, systemd timers

## phase 3: guardian
- health check scripts (disk, memory, services, connectivity)
- cron/systemd timers for periodic checks
- `/loop` integration for continuous monitoring
- notification channels: whatsapp, slack, git issues
- remote orchestration — users can trigger actions via external channels

</goals>

<existing_patterns>

patterns from the skogai ecosystem that apply here:

- **symlink staging**: `.claude/{skills,commands,hooks,agents}` → `../` counterparts
- **env var portability**: all paths use `~/` or env vars, not hardcoded paths
- **gptme-contrib**: has systemd status monitoring, autonomous loop runners, agent workspace setup docs
- **small-hours**: deployment via GitHub Actions + SSH + Tailscale (reference pattern)
- **dotfiles**: `gptme-contrib/dotfiles/install.sh` handles git hooks, config symlinks
- **claude-memory**: installable plugin with install scripts

</existing_patterns>

<routing>

| need | go to |
|------|-------|
| open questions | QUESTIONS.md |
| ansible playbooks | ansible/ (tbd) |
| bootstrap script | bootstrap.sh (tbd) |
| health checks | guardian/ (tbd) |
| notification config | guardian/notifications/ (tbd) |

</routing>

<conventions>

follows @.skogai/knowledge/patterns/style/CLAUDE.md conventions.
commits: `{type}(headquarters): {description}`

</conventions>
