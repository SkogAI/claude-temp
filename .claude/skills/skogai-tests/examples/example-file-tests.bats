#!/usr/bin/env bats

# example: testing file operations

load ../test-helper

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "can create and verify files" {
    echo "test content" > test.txt
    assert_file_exists "test.txt"
}

@test "can create and verify directories" {
    mkdir -p nested/dir/structure
    assert_dir_exists "nested/dir/structure"
}

@test "file contains expected content" {
    echo "hello world" > greeting.txt
    run cat greeting.txt
    assert_success
    assert_output_equals "hello world"
}

@test "script creates expected output file" {
    # example: test a script that generates a file
    cat > generate.sh << 'EOF'
#!/bin/bash
echo "generated content" > output.txt
EOF
    chmod +x generate.sh

    run ./generate.sh
    assert_success
    assert_file_exists "output.txt"

    run cat output.txt
    assert_output_contains "generated content"
}
