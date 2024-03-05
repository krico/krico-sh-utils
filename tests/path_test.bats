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
  import log
  import path
}

teardown() {
  if [[ -n "${TEMPORARY_FOLDER}" ]]; then
    rm -rf "${TEMPORARY_FOLDER}"
  fi
}

@test "krico_path_add" {
  before="${PATH}"
  new_path="${TEMPORARY_FOLDER}/my/bin"
  mkdir -p "${new_path}"
  refute krico_path_add
  assert krico_path_add "${new_path}"
  assert_equal "${new_path}:${before}" "${PATH}"
}

@test "krico_path_add_end" {
  before="${PATH}"
  new_path="${TEMPORARY_FOLDER}/my/bin"
  mkdir -p "${new_path}"
  refute krico_path_add_end
  assert krico_path_add_end "${new_path}"
  assert_equal "${before}:${new_path}" "${PATH}"
}

@test "krico_relative_path" {
  assert_equal "$(krico_relative_path "/my/base/path" "/my/base/path/foo")" "foo"
  assert_equal "$(krico_relative_path "/my/base/path" "/my/base/path/foo/bar")" "foo/bar"
  assert_equal "$(krico_relative_path "/my/base/path" "/my/base/foo/bar")" "../foo/bar"
  assert_equal "$(krico_relative_path "/my/base/path" "/my/base/")" "../"
  assert_equal "$(krico_relative_path "/my/base/path" "/my/")" "../../"
  assert_equal "$(krico_relative_path "/my/base/path" "/")" "../../../"
  assert_equal "$(krico_relative_path "/my/base/path" "/bar")" "../../../bar"
  assert_equal "$(krico_relative_path "/" "/bar")" "/bar"
}
