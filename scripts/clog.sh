#!/usr/bin/env bash
# Show recent commits from both claude repos

./scripts/cgit.sh log --oneline -20
git log --oneline -20
