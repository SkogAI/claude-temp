#!/usr/bin/env bash
# test-bootstrap.sh — validate bootstrap steps against the soft-serve container
set -euo pipefail

CONTAINER="soft-serve"
PASS=0
FAIL=0

run() {
  docker exec "$CONTAINER" bash -c "export PATH=\"/home/skogix/.local/bin:\$PATH\" && $1" 2>&1
}

check() {
  local desc="$1" cmd="$2"
  if run "$cmd" >/dev/null 2>&1; then
    printf '\033[0;32m✓\033[0m %s\n' "$desc"
    PASS=$((PASS + 1))
  else
    printf '\033[0;31m✗\033[0m %s\n' "$desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== container state ==="
check "container is running"          "true"
check "user is skogix"                "[ \$(whoami) = skogix ]"
check "skogix in wheel group"         "id -nG | grep -q wheel"
check "arch linux"                    "grep -q 'ID=arch' /etc/os-release"
check "bootstrap mounted"            "[ -f /bootstrap/bootstrap.sh ]"

echo ""
echo "=== step 1: base deps ==="
check "git installed"                 "git --version"
check "curl installed"                "curl --version"
check "github-cli installed"          "gh --version"
check "uv installed"                  "uv --version"

echo ""
echo "=== step 1b: gh auth ==="
check "gh authenticated"              "gh auth status"
check "git credential helper set"     "gh auth setup-git && git config --global credential.helper | grep -q gh"

echo ""
echo "=== step 2: ansible ==="
check "ansible installed"             "ansible --version"
check "ansible-playbook available"    "which ansible-playbook"
check "ansible-vault available"       "which ansible-vault"
check "ansible-galaxy available"      "which ansible-galaxy"

echo ""
echo "=== step 3: ansible collections ==="
check "community.general installed"   "ansible-galaxy collection list | grep -q community.general"
check "kewlfft.aur installed"         "ansible-galaxy collection list | grep -q kewlfft.aur"
check "ansible.posix installed"       "ansible-galaxy collection list | grep -q ansible.posix"

echo ""
echo "=== step 4: users role ==="
check "wheel group exists"            "getent group wheel"
check "wheel has sudo"                "sudo cat /etc/sudoers.d/10-wheel 2>/dev/null | grep -q wheel"
check "aur_builder user exists"       "id aur_builder"
check "aur_builder in wheel"          "id -nG aur_builder | grep -q wheel"
check "yay installed"                 "which yay"

echo ""
echo "=== step 5: packages ==="
check "tmux installed"                "which tmux"
check "zsh installed"                 "which zsh"
check "ripgrep installed"             "which rg"
check "fzf installed"                 "which fzf"
check "jq installed"                  "which jq"
check "fd installed"                  "which fd"
check "bat installed"                 "which bat"
check "zoxide installed"              "which zoxide"
check "direnv installed"              "which direnv"

echo ""
echo "=== summary ==="
printf '%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
