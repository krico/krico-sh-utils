# +====================================================================================================
# | krico-sh-utils: lib/env.bash
# |
# | Persistent configurations for the environment
# |
# | Usage:
# | var=$(krico_env_get "FOO") # read config FOO into var
# | var=$(krico_env_get "FOO" "x") # read config FOO into var or "x" if unset
# |
# | krico_env_set "FOO" "x" # set config FOO=x
# |
# | # To persist an array or any kind of variable
# | # first you declare it
# | declare -a x=([1]=2 [3]=4)
# | # then "write" it
# | krico_declare_write x
# | # later you can read it
# | eval "$(krico_declare_read x)"
# |
# | # Find the next available file descriptor
# | local my_fd=$(krico_find_fd)
# +====================================================================================================

function krico_env_get() {
  local name="$1"
  local default="$2"
  if [[ -r "${KRICO_CONFIG}/env/${name}" ]]; then
    head -1 "${KRICO_CONFIG}/env/${name}"
  else
    echo "${default}"
  fi
}

function krico_env_set() {
  local name="$1"
  local value="$2"
  if echo "${value}" >"${KRICO_CONFIG}/env/${name}"; then
    return 0
  else
    echo "${FUNCNAME[0]}: ERROR '${name}'='${value}': $!" >&2
    return 1
  fi
}

function krico_declare_read() {
  local name="$1"
  if [[ -r "${KRICO_CONFIG}/env/${name}.declare" ]]; then
    cat "${KRICO_CONFIG}/env/${name}.declare"
  else
    echo "declare \"${name}\""
  fi
}

function krico_declare_write() {
  local name="$1"
  declare -p "${name}" >"${KRICO_CONFIG}/env/${name}.declare"
}

# Find the next available file descriptor to use
function krico_find_fd() {
  local fd=2
  local max=$(ulimit -n)
  while ((++fd < max)); do
    ! <&$fd && break
  done 2>/dev/null
  echo $fd
}
