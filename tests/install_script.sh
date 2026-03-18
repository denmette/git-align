#!/bin/bash

set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/test_helper.sh"

test_installer_works_outside_repo_root() {
  local temp_home
  local temp_cwd

  temp_home="$TEST_TMP/home"
  temp_cwd="$TEST_TMP/outside"

  mkdir -p "$temp_home" "$temp_cwd"

  (
    cd "$temp_cwd"
    HOME="$temp_home" bash "$TEST_ROOT/install.sh" >/dev/null
  )

  [ -x "$temp_home/.local/bin/git-align" ] || fail "expected installed executable in fallback bin directory"
  [ -f "$temp_home/.local/bin/git-align.version" ] || fail "expected installed version file in fallback bin directory"
}

main() {
  setup_test_tmp
  test_installer_works_outside_repo_root
  echo "PASS: install_script"
}

main "$@"
