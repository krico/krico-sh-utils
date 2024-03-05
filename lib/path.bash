# +====================================================================================================
# | krico-sh-utils: lib/path.bash
# |
# | Functions related to PATH and paths
# |
# | Depends:
# |   - log
# |
# | Usage:
# | krico_path_add <path> # adds <path> to the beginning of PATH (if not present)
# | krico_path_add_end <path> # adds <path> to the end of PATH (if not present)
# |
# | krico_relative_path <base> <path> # Example: krico_relative_path /my/path /my/foo -> "../foo"
# +====================================================================================================

function krico_path_add() {
  local path="$1"
  if [ -z "$path" ]; then
    krico_error "Usage: ${FUNCNAME[0]} path"
    return 1
  fi

  if [[ ":$PATH:" != *":${path}:"* ]]; then
    krico_trace "${FUNCNAME[0]}: adding '${path}' to PATH"
    PATH="${path}:${PATH}"
    export PATH
  else
    krico_trace "${FUNCNAME[0]}: '${path}' is already present in PATH"
  fi
}

function krico_path_add_end() {
  local path="$1"
  if [ -z "$path" ]; then
    krico_error "Usage: ${FUNCNAME[0]} path"
    return 1
  fi

  if [[ ":$PATH:" != *":${path}:"* ]]; then
    krico_trace "${FUNCNAME[0]}: adding '${path}' to end of PATH"
    PATH="${PATH}:${path}"
    export PATH
  else
    krico_trace "${FUNCNAME[0]}: '${path}' is already present in PATH"
  fi
}

function krico_relative_path() {
  local base="$1"
  local path="$2"
  local common_part="${base}"
  local result=""

  while [[ "${path#$common_part}" == "${path}" ]]; do
    common_part="$(dirname $common_part)"
    if [[ -z "$result" ]]; then
      result=".."
    else
      result="../$result"
    fi
  done

  if [[ $common_part == "/" ]]; then
    result="$result/"
  fi

  local forward_part="${path#$common_part}"

  if [[ -n "$result" && -n "$forward_part" ]]; then
    result="$result$forward_part"
  elif [[ -n $forward_part ]]; then
    # extra slash removal
    result="${forward_part:1}"
  fi

  echo $result
}
