#!/bin/bash

set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

create_remote_fixture() {
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

  git clone "$remote" "$updater" >/dev/null 2>&1
  git_test_init "$updater"
  echo "remote change" >> "$updater/README.md"
  git -C "$updater" add README.md
  git -C "$updater" commit -m "remote update" >/dev/null
  git -C "$updater" push origin main >/dev/null 2>&1
}

test_rebases_feature_branch_on_updated_default() {
  local workspace="$TEST_TMP/workspace"
  local repo="$workspace/repo"
  local before_feature_head
  local after_feature_head
  local current_branch
  local head_subject

  create_remote_fixture

  before_feature_head=$(git -C "$repo" rev-parse HEAD)
  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs" run_cli_in_dir "$workspace" --logs

  assert_status 0 "$status"
  assert_contains "$output" "✅ Success: 1"
  assert_contains "$output" "❌ Failed : 0"
  assert_contains "$output" "1/1 ✅ ./repo"

  current_branch=$(git -C "$repo" branch --show-current)
  assert_equals "feature" "$current_branch"

  git -C "$repo" fetch origin >/dev/null 2>&1
  git -C "$repo" merge-base --is-ancestor origin/main HEAD
  assert_git_clean "$repo"

  head_subject=$(git -C "$repo" log -1 --format=%s)
  assert_equals "feature work" "$head_subject"

  after_feature_head=$(git -C "$repo" rev-parse HEAD)
  if [ "$before_feature_head" = "$after_feature_head" ]; then
    fail "expected feature branch to be rebased onto updated main"
  fi

  assert_contains "$(cat "$repo/README.md")" "remote change"
}

test_updates_when_remote_default_branch_advances_with_empty_commit() {
  local remote="$TEST_TMP/empty-remote.git"
  local seed="$TEST_TMP/empty-seed"
  local workspace="$TEST_TMP/empty-workspace"
  local updater="$TEST_TMP/empty-updater"
  local repo="$workspace/repo"
  local before_main_head
  local after_main_head

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
  git clone "$remote" "$repo" >/dev/null 2>&1
  git_test_init "$repo"

  git clone "$remote" "$updater" >/dev/null 2>&1
  git_test_init "$updater"
  git -C "$updater" commit --allow-empty -m "empty remote update" >/dev/null
  git -C "$updater" push origin main >/dev/null 2>&1

  before_main_head=$(git -C "$repo" rev-parse HEAD)
  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs-empty" run_cli_in_dir "$workspace" --logs

  assert_status 0 "$status"
  assert_contains "$output" "✅ Success: 1"
  assert_contains "$output" "❌ Failed : 0"

  after_main_head=$(git -C "$repo" rev-parse HEAD)
  if [ "$before_main_head" = "$after_main_head" ]; then
    fail "expected main to advance after remote empty commit"
  fi

  assert_equals "main" "$(git -C "$repo" branch --show-current)"
  assert_git_clean "$repo"
  assert_equals "empty remote update" "$(git -C "$repo" log -1 --format=%s)"
}

main() {
  setup_test_tmp
  test_rebases_feature_branch_on_updated_default
  test_updates_when_remote_default_branch_advances_with_empty_commit
  echo "PASS: integration_rebase"
}

main "$@"
