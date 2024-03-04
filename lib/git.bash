# +====================================================================================================
# | krico-sh-utils: lib/git.bash
# |
# | Functions and configurations to enrich git
# |
# | Usage:
# | # function to call git
# | git [git options]
# | # run git pull in an existing repository
# | git_pull <repo_dir>
# +====================================================================================================

export KRICO_GIT="$(krico_env_get "GIT_EXE")"

if [[ -z "${KRICO_GIT}" || ! -x "${KRICO_GIT}" ]]; then
  echo "ERROR: git.bash: KRICO_GIT='${KRICO_GIT}' is invalid" >&2
  return 1
fi

function git() {
  "${KRICO_GIT}" "$@"
}

function git_pull() {
  local repo_dir="$1"
  if [[ -z "${repo_dir}" || ! -d "${repo_dir}" ]]; then
    echo "Usage: ${FUNCNAME[0]} <repo_dir>" >&2
    return 1
  fi
  git -C "${repo_dir}" pull
}

function git_config_global() {
  local user_config="$(krico_env_get USER_CONFIG)/gitconfig/global"
  if [ ! -f "${user_config}" ]; then
    krico_warn "${FUNCNAME[0]}: config not found '$user_config'"
    return 0
  fi

  krico_debug "${FUNCNAME[0]}: applying '$user_config'"
  local tmp=$(mktemp -t "${FUNCNAME[0]}")
  local fd=$(krico_find_fd)

  git config -f "$user_config" -l -z >"${tmp}"

  eval "exec ${fd}<'${tmp}'" #open fd

  while IFS=$'\n' read -u ${fd} -d $'\0' key value; do
    krico_trace "${FUNCNAME[0]}: git config --global '$key' '$value'"
    git config --global "$key" "$value"
  done

  eval "exec ${fd}>&-" # close fd
  rm -f "${tmp}"
  krico_info "${FUNCNAME[0]}: success."
  return 0
}
