#!/bin/bash

set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

create_dry_run_fixture() {
  local remote="$TEST_TMP/remote.git"
  local seed="$TEST_TMP/seed"
  local workspace="$TEST_TMP/workspace"
  local updater="$TEST_TMP/updater"

  git init --bare --initial-branch=main "$remote" >/dev/null
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
  git clone "$remote" "$workspace/repo" >/dev/null 2>&1
  git_test_init "$workspace/repo"
  git -C "$workspace/repo" switch -c feature >/dev/null 2>&1
  echo "feature work" > "$workspace/repo/feature.txt"
  git -C "$workspace/repo" add feature.txt
  git -C "$workspace/repo" commit -m "feature work" >/dev/null
  echo "local draft" >> "$workspace/repo/README.md"

  git clone "$remote" "$updater" >/dev/null 2>&1
  git_test_init "$updater"
  echo "remote change" >> "$updater/README.md"
  git -C "$updater" add README.md
  git -C "$updater" commit -m "remote update" >/dev/null
  git -C "$updater" push origin main >/dev/null 2>&1
}

test_dry_run_reports_actions_without_mutating_repo() {
  local workspace="$TEST_TMP/workspace"
  local repo="$workspace/repo"
  local before_head
  local after_head
  local current_branch
  local log_file

  create_dry_run_fixture

  before_head=$(git -C "$repo" rev-parse HEAD)
  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs" run_cli_in_dir "$workspace" --logs --dry-run

  assert_status 0 "$status"
  assert_contains "$output" "✅ Success: 1"
  assert_contains "$output" "❌ Failed : 0"

  current_branch=$(git -C "$repo" branch --show-current)
  assert_equals "feature" "$current_branch"

  after_head=$(git -C "$repo" rev-parse HEAD)
  assert_equals "$before_head" "$after_head"
  assert_git_status_contains "$repo" " M README.md"
  assert_git_stash_empty "$repo"
  assert_file_contains "$repo/README.md" "local draft"
  assert_contains "$output" "🧪 Dry run mode"

  log_file=$(find "$TEST_TMP/logs" -type f -name "*.log" | head -n 1)
  assert_file_contains "$log_file" "Would fetch --all --prune"
  assert_file_contains "$log_file" "Would stash local changes"
  assert_file_contains "$log_file" "Would rebase feature onto origin/main"
}

main() {
  setup_test_tmp
  test_dry_run_reports_actions_without_mutating_repo
  echo "PASS: integration_dry_run"
}

main "$@"
