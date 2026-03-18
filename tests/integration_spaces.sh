#!/bin/bash

set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

create_space_fixture() {
  local name="$1"
  local remote="$TEST_TMP/${name}-remote.git"
  local seed="$TEST_TMP/${name}-seed"
  local workspace="$TEST_TMP/${name}-workspace"
  local updater="$TEST_TMP/${name}-updater"
  local repo="$workspace/team repo"

  git init --bare "$remote" >/dev/null
  git clone "$remote" "$seed" >/dev/null 2>&1
  git_test_init "$seed"

  cat << EOF > "$seed/README.md"
# fixture
EOF

  git -C "$seed" add README.md
  git -C "$seed" commit -m "initial commit" >/dev/null
  git -C "$seed" branch -M main
  git -C "$seed" push -u origin main >/dev/null 2>&1
  git -C "$remote" symbolic-ref HEAD refs/heads/main

  mkdir -p "$workspace"
  git clone "$remote" "$repo" >/dev/null 2>&1
  git_test_init "$repo"
  git -C "$repo" switch -c feature >/dev/null 2>&1
  echo "feature work" > "$repo/feature.txt"
  git -C "$repo" add feature.txt
  git -C "$repo" commit -m "feature work" >/dev/null

  git clone "$remote" "$updater" >/dev/null 2>&1
  git_test_init "$updater"
  echo "remote change" >> "$updater/README.md"
  git -C "$updater" add README.md
  git -C "$updater" commit -m "remote update" >/dev/null
  git -C "$updater" push origin main >/dev/null 2>&1

  echo "$workspace"
}

assert_space_repo_success() {
  local workspace="$1"
  local repo="$workspace/team repo"
  local current_branch

  assert_status 0 "$status"
  assert_contains "$output" "✅ Success: 1"
  assert_contains "$output" "❌ Failed : 0"

  current_branch=$(git -C "$repo" branch --show-current)
  assert_equals "feature" "$current_branch"
  git -C "$repo" fetch origin >/dev/null 2>&1
  git -C "$repo" merge-base --is-ancestor origin/main HEAD
  assert_git_clean "$repo"
  assert_file_contains "$repo/README.md" "remote change"
}

test_handles_spaces_in_repo_paths_sequentially() {
  local workspace

  workspace=$(create_space_fixture "sequential")
  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs-sequential" run_cli_in_dir "$workspace" --logs
  assert_space_repo_success "$workspace"
}

test_handles_spaces_in_repo_paths_in_parallel() {
  local workspace

  workspace=$(create_space_fixture "parallel")
  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs-parallel" run_cli_in_dir "$workspace" --logs --parallel 2
  assert_space_repo_success "$workspace"
}

main() {
  setup_test_tmp
  test_handles_spaces_in_repo_paths_sequentially
  test_handles_spaces_in_repo_paths_in_parallel
  echo "PASS: integration_spaces"
}

main "$@"
