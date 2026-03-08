#!/usr/bin/env bash
# run-bootstrap.sh — run bootstrap.sh inside the soft-serve container
set -euo pipefail

CONTAINER="soft-serve"
PATH_PREFIX='export PATH="/home/skogix/.local/bin:$PATH"'

run() {
  docker exec "$CONTAINER" bash -c "$PATH_PREFIX && $1" 2>&1
}

log() { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }

# step 1: base deps
log "Step 1: base packages..."
run "sudo pacman -S --needed --noconfirm github-cli uv git"

# step 2: ansible via uv
log "Step 2: ansible via uv..."
run "uv tool install ansible-core 2>&1 || true"

# step 3: clone bootstrap
log "Step 3: clone bootstrap..."
run "rm -rf ~/bootstrap && git clone https://github.com/SkogAI/bootstrap.git ~/bootstrap"

# step 4: gh auth via vault-decrypted PAT
log "Step 4: gh auth..."
run "cd ~/bootstrap && ansible-vault view pat.vault --vault-password-file pat.password.example | gh auth login --with-token"
run "gh auth setup-git"
run "gh auth status"

log "Done. Run test-bootstrap.sh to verify."
