# How to Use This Skill

Hey Claude — I just added the "bash-testing-framework" skill. Can you set up bats testing for my bash project?

## Example Invocations

**Example 1: Setup**
Hey Claude — I just added the "bash-testing-framework" skill. Can you set up the testing framework in this project and create tests for my scripts?

**Example 2: Write Tests**
Hey Claude — I just added the "bash-testing-framework" skill. Can you write unit tests for `scripts/deploy.sh` covering both success and error cases?

**Example 3: Add Assertions**
Hey Claude — I just added the "bash-testing-framework" skill. My deploy script should create a `build/` directory and output "deployed successfully". Can you write tests that verify this?

**Example 4: Git Testing**
Hey Claude — I just added the "bash-testing-framework" skill. I need tests for my git hook scripts. Can you set up isolated git repo tests?

## What to Provide

- Path to the bash project
- Scripts to test (or let Claude discover them)
- Expected behaviors and edge cases (optional)

## What You'll Get

- `testing-framework/` directory with all framework files
- `tests/unit/` and `tests/integration/` directories
- Test files with proper load paths, setup/teardown, and assertions
- Framework verified with example tests
