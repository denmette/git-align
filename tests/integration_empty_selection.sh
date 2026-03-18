#!/bin/bash

set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

assert_empty_selection_success() {
  assert_status 0 "$status"
  assert_contains "$output" "📦 Selected 0 repositories"
  assert_contains "$output" "✅ Success: 0"
  assert_contains "$output" "❌ Failed : 0"
}

test_handles_empty_selection_sequentially() {
  local workspace="$TEST_TMP/empty-sequential"

  mkdir -p "$workspace"
  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs-sequential" run_cli_in_dir "$workspace" --logs
  assert_empty_selection_success
}

test_handles_empty_selection_in_parallel() {
  local workspace="$TEST_TMP/empty-parallel"

  mkdir -p "$workspace"
  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs-parallel" run_cli_in_dir "$workspace" --logs --parallel 2
  assert_empty_selection_success
}

main() {
  setup_test_tmp
  test_handles_empty_selection_sequentially
  test_handles_empty_selection_in_parallel
  echo "PASS: integration_empty_selection"
}

main "$@"
