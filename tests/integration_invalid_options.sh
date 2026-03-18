#!/bin/bash

set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

assert_invalid_option_failure() {
  local expected_message="$1"

  assert_status 1 "$status"
  assert_contains "$output" "$expected_message"
}

test_rejects_unknown_option_in_workspace_context() {
  local workspace="$TEST_TMP/invalid-unknown"

  mkdir -p "$workspace"
  run_cli_in_dir "$workspace" --bogus
  assert_invalid_option_failure "Unknown option: --bogus"
}

test_rejects_missing_since_value_in_workspace_context() {
  local workspace="$TEST_TMP/invalid-since"

  mkdir -p "$workspace"
  run_cli_in_dir "$workspace" --since
  assert_invalid_option_failure "Option --since requires a value"
}

test_rejects_invalid_parallel_value_in_workspace_context() {
  local workspace="$TEST_TMP/invalid-parallel"

  mkdir -p "$workspace"
  run_cli_in_dir "$workspace" --parallel 0
  assert_invalid_option_failure "Option --parallel requires a positive integer"
}

main() {
  setup_test_tmp
  test_rejects_unknown_option_in_workspace_context
  test_rejects_missing_since_value_in_workspace_context
  test_rejects_invalid_parallel_value_in_workspace_context
  echo "PASS: integration_invalid_options"
}

main "$@"
