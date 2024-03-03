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

  import env
}

teardown() {
  if [[ -n "${TEMPORARY_FOLDER}" ]]; then
    rm -rf "${TEMPORARY_FOLDER}"
  fi
}

@test "krico_env_get" {
  assert_equal "" "$(krico_env_get TEST1)"
  assert_equal "yes" "$(krico_env_get TEST1 yes)"

  echo "BAR" >"${KRICO_CONFIG}/env/FOO"
  assert_equal "BAR" "$(krico_env_get FOO)"
  assert_equal "BAR" "$(krico_env_get FOO yes)"
}

@test "krico_env_set" {
  assert_equal "" "$(krico_env_get V1)"
  krico_env_set V1 5
  assert_equal 5 "$(krico_env_get V1)"
}

@test "krico_declare_read" {
  echo 'declare test_var="bob"' >"${KRICO_CONFIG}/env/test_var.declare"
  eval "$(krico_declare_read test_var)"
  assert_equal "bob" "${test_var}"
}

@test "krico_declare_write" {
  declare -a x=([1]=2 [3]=4)
  assert_equal 2 "${x[1]}"
  assert_equal 4 "${x[3]}"

  krico_declare_write x

  x[3]=5
  assert_equal 5 "${x[3]}"

  eval "$(krico_declare_read x)"
  assert_equal 2 "${x[1]}"
  assert_equal 4 "${x[3]}"
}
