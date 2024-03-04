setup() {
  load "${KRICO_BATS_PREFIX}/lib/bats-support/load"
  load "${KRICO_BATS_PREFIX}/lib/bats-assert/load"

  TESTS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")"; pwd)"
  KRICO_LIB="$(cd "${TESTS_DIR}/../lib";pwd)"

  TEMPORARY_FOLDER="$(mktemp -d)"
  KRICO_CONFIG="${TEMPORARY_FOLDER}/.krico-sh-utils"
  KRICO_USER_CONFIG="${TEMPORARY_FOLDER}/uc"
  cd "${TEMPORARY_FOLDER}"
  mkdir -p "${KRICO_CONFIG}/env"
  mkdir -p "${KRICO_USER_CONFIG}/vcs"

  source "${KRICO_LIB}/import.bash"
  import env
  import log
  import update/get_code
}

teardown() {
  if [[ -n "${TEMPORARY_FOLDER}" ]]; then
    rm -rf "${TEMPORARY_FOLDER}"
  fi
}

@test "get_server_alias" {
  assert_equal "$(get_server_alias "example.com")" "example.com"
  touch "${KRICO_USER_CONFIG}/vcs/server_aliases"
  assert_equal "$(get_server_alias "example.com")" "example.com"
  echo "EX,example.com" >>"${KRICO_USER_CONFIG}/vcs/server_aliases"
  assert_equal "$(get_server_alias "example.com")" "EX"

  echo "# Another example" >>"${KRICO_USER_CONFIG}/vcs/server_aliases"
  echo "EX2,example.com.br" >>"${KRICO_USER_CONFIG}/vcs/server_aliases"
  assert_equal "$(get_server_alias "example.com")" "EX"
  assert_equal "$(get_server_alias "example.com.br")" "EX2"
}
