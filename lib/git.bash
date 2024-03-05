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

function git_config_repo() {
  local repo_dir="$1"
  local repo_name
  local user_config

  if [[ -z "${repo_dir}" || ! -d "${repo_dir}" ]]; then
    krico_error "Usage: ${FUNCNAME[0]} <repo_dir>"
    return 1
  fi
  repo_name="$(basename "${repo_dir}")"
  local uc="$(krico_env_get USER_CONFIG)"
  if [[ -z "${uc}" ]]; then
    krico_debug "${FUNCNAME[0]}: USER_CONFIG is not set, skipping repository configuration of '${repo_name}'"
    return 0
  fi
  if [[ -r "${uc}/gitconfig/repo.${repo_name}" ]]; then
    user_config="${uc}/gitconfig/repo.${repo_name}"
  elif [[ -r "${uc}/gitconfig/repo" ]]; then
    user_config="${uc}/gitconfig/repo"
  else
    krico_debug "${FUNCNAME[0]}: no repo config found, skipping repository configuration of '${repo_name}'"
    return 0
  fi

  if [ ! -f "${user_config}" ]; then
    krico_warn "${FUNCNAME[0]}: not a file '$user_config'"
    return 1
  fi

  krico_debug "${FUNCNAME[0]}: applying repo config '$user_config' to '${repo_name}'"
  local tmp=$(mktemp -t "${FUNCNAME[0]}")
  local fd=$(krico_find_fd)

  git config -f "$user_config" -l -z >"${tmp}"

  eval "exec ${fd}<'${tmp}'" #open fd

  while IFS=$'\n' read -u ${fd} -d $'\0' key value; do
    krico_trace "${FUNCNAME[0]}: git -C '${repo_dir}' config --local '$key' '$value'"
    git -C "${repo_dir}" config --local "$key" "$value"
  done

  eval "exec ${fd}>&-" # close fd
  rm -f "${tmp}"
  krico_info "${FUNCNAME[0]}: repo_dir '${repo_dir}' success."
  return 0
}
