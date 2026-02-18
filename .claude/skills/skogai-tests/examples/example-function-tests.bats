#!/usr/bin/env bats

# example: testing bash functions from a sourced script

load ../test-helper

setup() {
  setup_test_dir

  # create a simple script with functions to test
  cat >"$TEST_DIR/functions.sh" <<'EOF'
#!/bin/bash

greet() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "ERROR: name required"
        return 1
    fi
    echo "hello, $name!"
}

add() {
    local a="$1"
    local b="$2"
    echo $((a + b))
}
EOF

  source "$TEST_DIR/functions.sh"
}

teardown() {
  teardown_test_dir
}

@test "greet function requires name argument" {
  run greet
  assert_failure
  assert_output_contains "ERROR: name required"
}

@test "greet function produces greeting" {
  run greet "world"
  assert_success
  assert_output_equals "hello, world!"
}

@test "add function performs addition" {
  run add 2 3
  assert_success
  assert_output_equals "5"
}
