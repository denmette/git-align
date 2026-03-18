#!/bin/bash

set -u

TEST_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLI="$TEST_ROOT/bin/git-align"
TEST_TMP=""

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_status() {
  local expected="$1"
  local actual="$2"

  if [ "$expected" -ne "$actual" ]; then
    fail "expected exit code $expected, got $actual"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    fail "expected output to contain: $needle"
  fi
}

assert_equals() {
  local expected="$1"
  local actual="$2"

  if [ "$expected" != "$actual" ]; then
    fail "expected '$expected', got '$actual'"
  fi
}

assert_file_contains() {
  local file="$1"
  local needle="$2"

  if ! grep -Fq "$needle" "$file"; then
    fail "expected $file to contain: $needle"
  fi
}

run_cli() {
  set +e
  output="$(bash "$CLI" "$@" 2>&1)"
  status=$?
  set -e
}

run_cli_in_dir() {
  local dir="$1"
  shift

  set +e
  output="$(cd "$dir" && bash "$CLI" "$@" 2>&1)"
  status=$?
  set -e
}

setup_test_tmp() {
  TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/git-align-test-XXXX")
  trap 'rm -rf "$TEST_TMP"' EXIT
}

git_test_init() {
  local repo="$1"
  git -C "$repo" config user.name "git-align test"
  git -C "$repo" config user.email "git-align@example.com"
  git -C "$repo" config commit.gpgsign false
}

assert_git_clean() {
  local repo="$1"
  local status_output

  status_output=$(git -C "$repo" status --short)
  if [ -n "$status_output" ]; then
    fail "expected clean working tree in $repo, got: $status_output"
  fi
}

assert_git_status_contains() {
  local repo="$1"
  local needle="$2"
  local status_output

  status_output=$(git -C "$repo" status --short)
  if [[ "$status_output" != *"$needle"* ]]; then
    fail "expected git status in $repo to contain '$needle', got: $status_output"
  fi
}

assert_git_stash_contains() {
  local repo="$1"
  local needle="$2"
  local stash_output

  stash_output=$(git -C "$repo" stash list)
  if [[ "$stash_output" != *"$needle"* ]]; then
    fail "expected git stash list in $repo to contain '$needle', got: $stash_output"
  fi
}
