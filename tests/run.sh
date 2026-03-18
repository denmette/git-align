#!/bin/bash

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

cd "$ROOT"

bash -n bin/git-align

for test_file in tests/*.sh; do
  case "$test_file" in
    tests/run.sh|tests/test_helper.sh)
      continue
      ;;
  esac

  bash "$test_file"
done
