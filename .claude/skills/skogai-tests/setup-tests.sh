#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🧪 setting up test environment"
echo ""

# check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "📦 installing bats (bash automated testing system)..."

    # try different installation methods
    if command -v brew &> /dev/null; then
        echo "  using homebrew..."
        brew install bats-core
    elif command -v npm &> /dev/null; then
        echo "  using npm..."
        npm install -g bats
    elif command -v apt-get &> /dev/null; then
        echo "  using apt-get..."
        sudo apt-get update && sudo apt-get install -y bats
    elif command -v pacman &> /dev/null; then
        echo "  using pacman..."
        sudo pacman -S bats
    else
        echo "❌ no supported package manager found"
        echo "please install bats manually:"
        echo "  https://github.com/bats-core/bats-core#installation"
        exit 1
    fi
else
    echo "✅ bats is already installed: $(command -v bats)"
fi

# create test directories if they don't exist
mkdir -p "$PROJECT_ROOT/tests"/{unit,integration,fixtures}

echo ""
echo "✅ test environment ready!"
echo ""
echo "to run tests:"
echo "  cd $PROJECT_ROOT"
echo "  bats tests/unit/*.bats"
echo ""
echo "to run a specific test file:"
echo "  bats tests/unit/example.bats"
