# +====================================================================================================
# | krico-sh-utils: lib/git.bash
# |
# | Functions and configurations to enrich git
# |
# | Usage:
# |
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
