#!/usr/bin/env bash
# Wrapper for bare git repo claude global
# Git dir: /mnt/sda1/claude-global.git
# Work tree: $HOME

exec git --git-dir="/mnt/sda1/claude-global.git" --work-tree="/home/skogix" "$@"
