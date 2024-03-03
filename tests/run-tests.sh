#!/usr/bin/env bash
# +====================================================================================================
# | krico-sh-utils: tests/run-tests.sh
# |
# | Runs all tests
# +====================================================================================================

TESTS_DIR="$(cd "$(dirname "$0")"; pwd)"

if [[ -x /opt/homebrew/bin/bats ]]; then
  export KRICO_BATS_PREFIX=/opt/homebrew
  /opt/homebrew/bin/bats \
    --show-output-of-passing-tests \
    $TESTS_DIR
fi