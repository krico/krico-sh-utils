# +====================================================================================================
# | krico-sh-utils: lib/log.bash
# |
# | Logging messages at different log-levels
# |
# | Usage:
# |
# | krico_trace "This is a TRACE message"
# | krico_debug "This is a DEBUG message"
# | krico_info "This is a INFO message"
# | krico_warn "This is a WARN message"
# | krico_error "This is a ERROR message"
# | krico_exit "Cannot continue..." # will log with krico_error and exit 1
# +====================================================================================================

export KRICO_LOGLEVEL="$(krico_env_get "LOGLEVEL" 30)"

export KRICO_LEVEL_TRACE=0
export KRICO_LEVEL_DEBUG=10
export KRICO_LEVEL_INFO=20
export KRICO_LEVEL_WARN=30
export KRICO_LEVEL_ERROR=40

function krico_log_level_name() {
  local names=([${KRICO_LEVEL_TRACE}]=TRACE
               [${KRICO_LEVEL_DEBUG}]=DEBUG
               [${KRICO_LEVEL_INFO}]=INFO
               [${KRICO_LEVEL_WARN}]=WARN
               [${KRICO_LEVEL_ERROR}]=ERROR)
  local level="$1"
  echo "${names[${level}]}"
}

function krico_log_enabled() {
  local level=$1
  if [[ ${level} -lt ${KRICO_LOGLEVEL:-30} ]]; then
    return 1;
  else
    return 0;
  fi
}

function krico_log() {
  local level=$1
  # If level is unset it becomes 30/WARN
  if [[ ${level} -lt ${KRICO_LOGLEVEL:-30} ]]; then
    return 0
  fi
  shift
  printf "[%s] %-5s - %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$(krico_log_level_name $level)" "$@" >&2
}

function krico_trace_enabled() { krico_log_enabled $KRICO_LEVEL_TRACE; }
function krico_debug_enabled() { krico_log_enabled $KRICO_LEVEL_DEBUG; }
function krico_info_enabled() { krico_log_enabled $KRICO_LEVEL_INFO; }
function krico_warn_enabled() { krico_log_enabled $KRICO_LEVEL_WARN; }
function krico_error_enabled() { krico_log_enabled $KRICO_LEVEL_ERROR; }

function krico_trace() {
  krico_log $KRICO_LEVEL_TRACE "$@"
}

function krico_debug() {
  krico_log $KRICO_LEVEL_DEBUG "$@"
}

function krico_info() {
  krico_log $KRICO_LEVEL_INFO "$@"
}

function krico_warn() {
  krico_log $KRICO_LEVEL_WARN "$@"
}

function krico_error() {
  krico_log $KRICO_LEVEL_ERROR "$@"
}

function krico_exit() {
  krico_error "$@"
  exit 1
}
