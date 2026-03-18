#!/bin/bash

set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

create_untracked_fixture() {
  local remote="$TEST_TMP/remote.git"
  local seed="$TEST_TMP/seed"
  local workspace="$TEST_TMP/workspace"
  local updater="$TEST_TMP/updater"

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
  git clone "$remote" "$workspace/repo" >/dev/null 2>&1
  git_test_init "$workspace/repo"

  git -C "$workspace/repo" switch -c feature >/dev/null 2>&1
  cat << EOF > "$workspace/repo/branch-only.txt"
local draft
EOF

  git clone "$remote" "$updater" >/dev/null 2>&1
  git_test_init "$updater"
  cat << EOF > "$updater/branch-only.txt"
tracked on main
EOF
  git -C "$updater" add branch-only.txt
  git -C "$updater" commit -m "add tracked file" >/dev/null
  git -C "$updater" push origin main >/dev/null 2>&1
}

test_fails_when_untracked_restore_conflicts() {
  local workspace="$TEST_TMP/workspace"
  local repo="$workspace/repo"
  local current_branch

  create_untracked_fixture

  GIT_ALIGN_LOG_DIR="$TEST_TMP/logs" run_cli_in_dir "$workspace" --logs

  assert_status 1 "$status"
  assert_contains "$output" "✅ Success: 0"
  assert_contains "$output" "❌ Failed : 1"

  current_branch=$(git -C "$repo" branch --show-current)
  assert_equals "feature" "$current_branch"
  assert_file_contains "$repo/branch-only.txt" "tracked on main"
  assert_git_clean "$repo"
  assert_git_stash_contains "$repo" "auto-update"
}

main() {
  setup_test_tmp
  test_fails_when_untracked_restore_conflicts
  echo "PASS: integration_untracked"
}

main "$@"
