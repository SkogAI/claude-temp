#!/usr/bin/env bats

# example: testing scripts that interact with git

load ../test-helper

setup() {
  setup_test_dir
  setup_git_repo
}

teardown() {
  teardown_test_dir
}

@test "git repo is initialized" {
  run git status
  assert_success
}

@test "can create and commit files" {
  echo "new content" >new-file.txt
  git add new-file.txt
  run git commit -m "add new file"
  assert_success
  assert_output_contains "add new file"
}

@test "can check git log" {
  run git log --oneline
  assert_success
  assert_output_contains "Initial commit"
}
