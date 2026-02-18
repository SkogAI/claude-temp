---
name: bash-testing-framework
description: Sets up and uses a portable bats-core testing framework for bash script projects with assertions, test helpers, and isolated test environments
---

# Bash Testing Framework

Portable, lightweight testing framework built on bats-core. Designed to be copied into any bash project as a self-contained testing solution.

## Capabilities

- **Framework Setup**: Install bats-core and create standard test directory structure
- **Test Scaffolding**: Generate new test files from templates with correct load paths
- **Assertions**: Provide exit status, output, file, and directory assertions
- **Test Isolation**: Temporary directories per test with automatic cleanup
- **Git Testing**: Mock git repositories for testing git-dependent scripts
- **Script Sourcing**: Load bash functions without executing main script logic
- **Conditional Skipping**: Skip tests when optional dependencies are missing

## Architecture

### Copy-and-Use Model

The framework follows a portable, self-contained design:

1. Copy the entire `testing-framework/` directory into the target bash project
2. Run `setup-tests.sh` to install bats and create `tests/{unit,integration,fixtures}/`
3. Tests load utilities via `load ../../testing-framework/test-helper`

All paths are relative and project-agnostic. The framework discovers the project root dynamically via `BASH_SOURCE[0]`.

### Component Relationships

```
setup-tests.sh
  └─> installs bats-core (brew → npm → apt-get → pacman)
  └─> creates tests/{unit,integration,fixtures}/ in parent project

test-helper.bash
  └─> loaded by test files via `load ../testing-framework/test-helper`
  └─> exports PROJECT_ROOT (parent of testing-framework/)
  └─> exports SCRIPTS_DIR (defaults to $PROJECT_ROOT/scripts, overridable)
  └─> provides setup/teardown/assertion functions

templates/basic-script.bats.template
  └─> boilerplate for new test files
  └─> demonstrates correct load path and common patterns

examples/*.bats
  └─> executable examples showing test patterns
  └─> double as verification tests for the framework itself
```

### Environment Variables

**Automatic** (set by `test-helper.bash`):
- `PROJECT_ROOT` — discovered via `$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)`, points to the parent of `testing-framework/`
- `SCRIPTS_DIR` — defaults to `$PROJECT_ROOT/scripts`, override with `export SCRIPTS_DIR="$PROJECT_ROOT/bin"`

**Per-test** (set by helper functions):
- `TEST_DIR` — temporary directory created by `setup_test_dir()`, cleaned by `teardown_test_dir()`

## Setup

### Install Framework

```bash
# copy framework into target project
cp -r testing-framework /path/to/your/project/

# run setup
cd /path/to/your/project
./testing-framework/setup-tests.sh
```

### Run Tests

```bash
bats tests/unit/*.bats              # all unit tests
bats tests/unit/specific.bats       # specific test file
bats tests/integration/*.bats       # integration tests
bats --tap tests/unit/*.bats         # TAP output (verbose)
bats examples/*.bats                # verify framework works
```

## Available Helpers

### Setup/Teardown

- `setup_test_dir` — creates temporary directory, sets `$TEST_DIR`, cd's into it
- `teardown_test_dir` — removes `$TEST_DIR` if it exists
- `setup_git_repo` — initializes a throw-away git repo with initial commit in `$TEST_DIR`
- `source_script "script.sh"` — sources `$SCRIPTS_DIR/script.sh` with `SOURCING_FOR_TESTS=1` to skip main logic

### Assertions

All assertions expect bats `run` to have been called first (`$status` and `$output` are set by `run`).

- `assert_success` — `$status` is 0
- `assert_failure` — `$status` is non-zero
- `assert_output_contains "text"` — `$output` contains string
- `assert_output_not_contains "text"` — `$output` does not contain string
- `assert_output_equals "text"` — `$output` exactly matches string
- `assert_file_exists "path"` — file exists at path
- `assert_dir_exists "path"` — directory exists at path

### Utilities

- `skip_if_missing "command"` — skip test if command is not installed

## Test Patterns

### Testing bash functions from a script

```bash
#!/usr/bin/env bats
load ../../testing-framework/test-helper

setup() {
    setup_test_dir
    cat > "$TEST_DIR/functions.sh" << 'EOF'
greet() {
    local name="$1"
    [[ -z "$name" ]] && { echo "ERROR: name required"; return 1; }
    echo "hello, $name!"
}
EOF
    source "$TEST_DIR/functions.sh"
}

teardown() { teardown_test_dir; }

@test "greet requires name" {
    run greet
    assert_failure
    assert_output_contains "ERROR: name required"
}

@test "greet produces greeting" {
    run greet "world"
    assert_success
    assert_output_equals "hello, world!"
}
```

### Testing git operations

```bash
#!/usr/bin/env bats
load ../../testing-framework/test-helper

setup() {
    setup_test_dir
    setup_git_repo
}

teardown() { teardown_test_dir; }

@test "git repo is initialized" {
    run git status
    assert_success
}

@test "can create and commit files" {
    echo "content" > new-file.txt
    git add new-file.txt
    run git commit -m "add file"
    assert_success
}
```

### Testing file operations

```bash
#!/usr/bin/env bats
load ../../testing-framework/test-helper

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

@test "can create and verify files" {
    echo "test content" > test.txt
    assert_file_exists "test.txt"
}

@test "script creates expected output" {
    cat > generate.sh << 'EOF'
#!/bin/bash
echo "generated" > output.txt
EOF
    chmod +x generate.sh
    run ./generate.sh
    assert_success
    assert_file_exists "output.txt"
}
```

### Skipping tests conditionally

```bash
@test "requires docker" {
    skip_if_missing docker
    run docker ps
    assert_success
}
```

### Testing project scripts

```bash
@test "project script works" {
    run "$SCRIPTS_DIR/my-script.sh" args
    assert_success
    assert_output_contains "expected"
}
```

### Custom scripts directory

```bash
# override SCRIPTS_DIR for projects that use bin/ instead of scripts/
export SCRIPTS_DIR="$PROJECT_ROOT/bin"
```

## How to Use

"Set up bats testing for this bash project"
"Write unit tests for this bash script using the testing framework"
"Add a test for the deploy script that checks error handling"
"Create integration tests for the git workflow scripts"

## File Conventions

- Test files: `tests/unit/*.bats`, `tests/integration/*.bats`
- Example files: `example-{category}-tests.bats`
- One test file per script being tested
- Use `$TEST_DIR` for all temporary files — never pollute the real filesystem

## Best Practices

1. Always call `run` before assertions — assertions check `$status` and `$output`
2. Use `setup_test_dir` / `teardown_test_dir` for isolation
3. Test both success and failure cases
4. Use descriptive `@test` names (shown in bats output)
5. Skip optional dependency tests with `skip_if_missing`
6. Create test fixtures in `$TEST_DIR`, never depend on external files
7. Source scripts with `source_script` to test functions without side effects

## Limitations

- Requires bats-core (auto-installed by `setup-tests.sh`)
- Only tests bash scripts and functions (not other languages)
- `source_script` requires scripts to check `SOURCING_FOR_TESTS` to skip main logic
- Package manager detection tries brew → npm → apt-get → pacman in order
