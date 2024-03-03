# +====================================================================================================
# | krico-sh-utils: lib/import.bash
# |
# | Load so-called bash modules with functions and commands
# |
# | Usage:
# |   import "my_module" # Will load from lib/my_module.bash
# |   import "/path/to/my_module.bash" # Will load from /path/to/my_module.bash
# |
# | Best practice (check the return code):
# |   import "log" || exit 1
# +====================================================================================================

function import_impl() {
  local module="$1"
  local optional="$2"

  if [[ -z "$module" ]]; then
    echo "${FUNCNAME[0]}: <module> [0|1]" >&2
    return 1
  fi

  if [[ -z "${KRICO_LIB}" ]]; then
    echo "${FUNCNAME[0]}: KRICO_LIB is empty" >&2
    return 1
  fi

  if [[ -r "${KRICO_LIB}/${module}.bash" ]]; then
    source "${KRICO_LIB}/${module}.bash"
  elif [[ -r "${KRICO_LIB}/${module}" ]]; then
    source "${KRICO_LIB}/${module}"
  elif [[ -r "${module}" ]]; then
    source "${module}"
  else
    if [[ $optional == 0 ]]; then
      echo "${FUNCNAME[0]}: module '${module}' not found" >&2
      return 1
    else
      return 0
    fi
  fi

}

function import() {
  import_impl "$1" 0
}

function import_optional() {
  import_impl "$1" 1
}
