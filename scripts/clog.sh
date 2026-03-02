#!/usr/bin/env bash
# Show recent commits from both claude repos

claude-dotfiles log --oneline --stat -20 >/tmp/clog.txt
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" >>/tmp/clog.txt
git log --oneline --stat -20 >>/tmp/clog.txt
