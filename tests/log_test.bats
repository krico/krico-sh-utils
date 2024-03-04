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
}

teardown() {
  if [[ -n "${TEMPORARY_FOLDER}" ]]; then
    rm -rf "${TEMPORARY_FOLDER}"
  fi
}

@test "krico_log_level_name" {
  assert_equal "$(krico_log_level_name $KRICO_LEVEL_TRACE)" "TRACE"
  assert_equal "$(krico_log_level_name $KRICO_LEVEL_DEBUG)" "DEBUG"
  assert_equal "$(krico_log_level_name $KRICO_LEVEL_INFO)" "INFO"
  assert_equal "$(krico_log_level_name $KRICO_LEVEL_WARN)" "WARN"
  assert_equal "$(krico_log_level_name $KRICO_LEVEL_ERROR)" "ERROR"
}

@test "krico_log_enabled" {
  KRICO_LOGLEVEL=$KRICO_LEVEL_ERROR
  let KRICO_LOGLEVEL+=1
  refute krico_error_enabled
  refute krico_warn_enabled
  refute krico_info_enabled
  refute krico_debug_enabled
  refute krico_trace_enabled

  KRICO_LOGLEVEL=$KRICO_LEVEL_ERROR
  assert krico_error_enabled
  refute krico_warn_enabled
  refute krico_info_enabled
  refute krico_debug_enabled
  refute krico_trace_enabled

  KRICO_LOGLEVEL=$KRICO_LEVEL_WARN
  assert krico_error_enabled
  assert krico_warn_enabled
  refute krico_info_enabled
  refute krico_debug_enabled
  refute krico_trace_enabled

  KRICO_LOGLEVEL=$KRICO_LEVEL_INFO
  assert krico_error_enabled
  assert krico_warn_enabled
  assert krico_info_enabled
  refute krico_debug_enabled
  refute krico_trace_enabled

  KRICO_LOGLEVEL=$KRICO_LEVEL_DEBUG
  assert krico_error_enabled
  assert krico_warn_enabled
  assert krico_info_enabled
  assert krico_debug_enabled
  refute krico_trace_enabled

  KRICO_LOGLEVEL=$KRICO_LEVEL_TRACE
  assert krico_error_enabled
  assert krico_warn_enabled
  assert krico_info_enabled
  assert krico_debug_enabled
  assert krico_trace_enabled
}

@test "krico_error" {
  KRICO_LOGLEVEL=$KRICO_LEVEL_ERROR

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'

  let KRICO_LOGLEVEL=$KRICO_LOGLEVEL+1
  run krico_error hello
  assert_success
  refute_output
}

@test "krico_warn" {
  KRICO_LOGLEVEL=$KRICO_LEVEL_WARN

  run krico_warn hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] WARN  - hello'

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'

  let KRICO_LOGLEVEL=$KRICO_LOGLEVEL+1

  run krico_warn hello
  assert_success
  refute_output

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'
}

@test "krico_info" {
  KRICO_LOGLEVEL=$KRICO_LEVEL_INFO

  run krico_info hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] INFO  - hello'

  run krico_warn hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] WARN  - hello'

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'

  let KRICO_LOGLEVEL=$KRICO_LOGLEVEL+1

  run krico_info hello
  assert_success
  refute_output

  run krico_warn hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] WARN  - hello'

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'
}

@test "krico_debug" {
  KRICO_LOGLEVEL=$KRICO_LEVEL_DEBUG

  run krico_debug hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] DEBUG - hello'

  run krico_info hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] INFO  - hello'

  run krico_warn hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] WARN  - hello'

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'

  let KRICO_LOGLEVEL=$KRICO_LOGLEVEL+1

  run krico_debug hello
  assert_success
  refute_output

  run krico_info hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] INFO  - hello'

  run krico_warn hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] WARN  - hello'

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'
}

@test "krico_trace" {
  KRICO_LOGLEVEL=$KRICO_LEVEL_TRACE

  run krico_trace hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] TRACE - hello'

  run krico_debug hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] DEBUG - hello'

  run krico_info hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] INFO  - hello'

  run krico_warn hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] WARN  - hello'

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'

  let KRICO_LOGLEVEL=$KRICO_LOGLEVEL+1

  run krico_trace hello
  assert_success
  refute_output

  run krico_debug hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] DEBUG - hello'

  run krico_info hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] INFO  - hello'

  run krico_warn hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] WARN  - hello'

  run krico_error hello
  assert_success
  assert_output --regexp '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] ERROR - hello'
}
