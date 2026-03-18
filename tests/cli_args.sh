#!/bin/bash

set -u

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

test_help() {
  run_cli --help
  assert_status 0 "$status"
  assert_contains "$output" "USAGE:"
  assert_contains "$output" "git-align [options]"
}

test_version_short_flag() {
  run_cli -V
  assert_status 0 "$status"
  assert_contains "$output" "git-align 0.2.0"
}

test_version_long_flag() {
  run_cli --version
  assert_status 0 "$status"
  assert_contains "$output" "git-align 0.2.0"
}

test_parallel_requires_value() {
  run_cli -p
  assert_status 1 "$status"
  assert_contains "$output" "Option -p requires a value"
}

test_since_requires_value() {
  run_cli --since
  assert_status 1 "$status"
  assert_contains "$output" "Option --since requires a value"
}

main() {
  test_help
  test_version_short_flag
  test_version_long_flag
  test_parallel_requires_value
  test_since_requires_value
  echo "PASS: cli_args"
}

main "$@"
