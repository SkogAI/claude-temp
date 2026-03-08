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

echo "=== container ==="
check "container is running"          "true"
check "user is skogix"                "[ \$(whoami) = skogix ]"
check "arch linux"                    "grep -q 'ID=arch' /etc/os-release"

echo ""
echo "=== step 1: base deps ==="
check "git installed"                 "git --version"
check "github-cli installed"          "gh --version"
check "uv installed"                  "uv --version"

echo ""
echo "=== step 2: ansible ==="
check "ansible installed"             "ansible --version"

echo ""
echo "=== step 3: bootstrap cloned ==="
check "bootstrap repo exists"         "[ -f ~/bootstrap/bootstrap.sh ]"
check "pat.vault exists"              "[ -f ~/bootstrap/pat.vault ]"

echo ""
echo "=== step 4: gh auth ==="
check "gh authenticated"              "gh auth status"

echo ""
echo "=== summary ==="
printf '%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
