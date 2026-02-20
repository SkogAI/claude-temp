#!/usr/bin/env bash
# Show recent commits from both claude repos

./scripts/cgit.sh log --oneline --stat -20
git log --oneline --stat -20
