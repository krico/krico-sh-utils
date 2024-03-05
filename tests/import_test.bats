setup() {
  load "${KRICO_BATS_PREFIX}/lib/bats-support/load"
  load "${KRICO_BATS_PREFIX}/lib/bats-assert/load"

  TESTS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")"; pwd)"
  KRICO_LIB="$(cd "${TESTS_DIR}/../lib";pwd)"

  TEMPORARY_FOLDER="$(mktemp -d)"
  KRICO_CONFIG="${TEMPORARY_FOLDER}/.krico-sh-utils"
  cd "${TEMPORARY_FOLDER}"
  mkdir -p "${KRICO_CONFIG}/env"

  source "${KRICO_LIB}/import.bash"
}

teardown() {
  if [[ -n "${TEMPORARY_FOLDER}" ]]; then
    rm -rf "${TEMPORARY_FOLDER}"
  fi
}

@test "import" {
  refute import foo
  assert_not_equal "$(type -t krico_env_get)" "function"
  assert import env
  assert_equal "$(type -t krico_env_get)" "function"
}

@test "import_optional" {
  assert import_optional foo
  assert_not_equal "$(type -t krico_env_get)" "function"
  assert import_optional env
  assert_equal "$(type -t krico_env_get)" "function"
}

@test "import (user_lib)" {
  refute import foo
  assert_not_equal "$(type -t foo)" "function"

  mkdir -p "${TEMPORARY_FOLDER}/lib"
  echo "function foo(){ echo ok; }" >"${TEMPORARY_FOLDER}/lib/foo.bash"
  export KRICO_USER_LIB="${TEMPORARY_FOLDER}/lib"
  assert import foo
  assert_equal "$(type -t foo)" "function"
}

@test "import_optional (user_lib)" {
  assert import_optional foo
  assert_not_equal "$(type -t foo)" "function"
  mkdir -p "${TEMPORARY_FOLDER}/lib"
  echo "function foo(){ echo ok; }" >"${TEMPORARY_FOLDER}/lib/foo.bash"
  export KRICO_USER_LIB="${TEMPORARY_FOLDER}/lib"
  assert import_optional foo
  assert_equal "$(type -t foo)" "function"
}

