#!/usr/bin/env bash
# set env variable KRICO_DEBUG=1 to enable debugging messages to stderr
KRICO_DEBUG="${KRICO_DEBUG:-0}"
# Path to directory where krico-sh-config keeps its configurations
KRICO_CONFIG_DIR="${HOME}/.krico-sh-utils"

function krico_debug() {
  if [[ "${KRICO_DEBUG}" != "1" ]]; then return; fi
  echo -n "DEBUG: " >&2
  echo "$@" >&2
}

function krico_fatal() {
  echo -n "FATAL: " >&2
  echo "$@" >&2
  exit 1
}

function krico_get_env() {
  local env_var_name="${1}"
  local default_value="${2}"
  if [[ -z "${env_var_name}" ]]; then krico_fatal "Usage: krico_get_env <ENV-VAR-NAME>"; fi
  local env_file="${KRICO_CONFIG_DIR}/env/${1}"
  if [[ -e "${env_file}" && -r "${env_file}" ]]; then
    head -1 "${env_file}"
  else
    echo "${default_value}"
  fi
}

if [[ ! -d "${HOME}" || ! -w "${HOME}" ]]; then
  krico_fatal "HOME='${HOME}' must be a directory with write permissions"
fi

_already_installed=0
_prefix_confirmed=1
_git_exe_confirmed=1

if [[ -e "${KRICO_CONFIG_DIR}" ]]; then
  krico_debug "found: KRICO_CONFIG_DIR='${KRICO_CONFIG_DIR}'"
  if [[ ! -d "${KRICO_CONFIG_DIR}" || ! -w "${KRICO_CONFIG_DIR}" ]]; then
    krico_fatal "KRICO_CONFIG_DIR='${KRICO_CONFIG_DIR}' must be a directory with write permissions"
  fi
  _already_installed=1
else
  krico_debug "missing: KRICO_CONFIG_DIR='${KRICO_CONFIG_DIR}'"
  _already_installed=0
fi

_prefix="$(krico_get_env "PREFIX")"
if [[ -z "${_prefix}" ]]; then
  _prefix_confirmed=0
  _prefix="$(
    cd "${HOME}"
    pwd
  )/Dev"
  krico_debug "default_prefix=${_prefix}"
fi
krico_debug "prefix='${_prefix}'"

_git_exe="$(krico_get_env "GIT_EXE")"
if [[ -z "${_git_exe}" ]]; then
  _git_exe_confirmed=0
  _git_exe="$(which git)"
  krico_debug "default_git_exe=${_git_exe}"
fi
krico_debug "git_exe='${_git_exe}'"

if [[ -z "${_git_exe}" || ! -x "${_git_exe}" ]]; then
  _git_exe_confirmed=0
fi

if [[ ${_new_install} == 1 ]]; then
  krico_debug "existing installation"
fi

_all_confirmed="no"
if [[ $_prefix_confirmed == 1 && $_git_exe_confirmed == 1 ]]; then
  krico_debug "all values are confirmed"
  _all_confirmed="yes"
fi

while [[ 1 ]]; do
  if [[ $_prefix_confirmed != 1 ]]; then
    echo -n "prefix (${_prefix}): "
    read p
    krico_debug "entered prefix='${p}'"
    if [[ -n "${p}" ]]; then
      _prefix="${p}"
    fi
  fi
  if [[ $_git_exe_confirmed != 1 ]]; then
    echo -n "git (${_git_exe}): "
    read p
    krico_debug "entered git_exe='${p}'"
    if [[ -n "${p}" ]]; then
      _git_exe="${p}"
    fi
  fi

  echo
  echo "+++ Configuration +++"
  echo "PREFIX       : ${_prefix}"
  echo "CONFIG       : ${KRICO_CONFIG_DIR}"
  echo "GIT          : ${_git_exe}"
  echo
  echo "This script will use GIT to install things in PREFIX and will store configurations in CONFIG"
  echo
  if [[ "${_all_confirmed}" != "yes" ]]; then
    _yesNo="?"
    while [[ 1 ]]; do
      echo -n "Are the above values correct? Can we proceed with the installation? (yes/no/quit): "
      read _yesNo
      case "${_yesNo}" in
      y | yes | Yes)
        _all_confirmed="yes"
        break
        ;;
      n | no | No)
        _all_confirmed="no"
        break
        ;;
      q | quit | Quit)
        echo "Installation aborted!"
        echo "Thank you for your time ;)"
        exit
        ;;
      *)
        echo "Please type either 'yes' or 'no'"
        ;;
      esac
    done
  fi
  if [[ "${_all_confirmed}" == "yes" ]]; then
    break
  fi
done

echo "Bootstrap started"

if [[ -z "${_git_exe}" || ! -x "${_git_exe}" ]]; then
  krico_fatal "Invalid git executable (git_exe='${_git_exe}')"
fi

if [[ ! -d "${KRICO_CONFIG_DIR}/env" ]]; then
  echo -n "Creating directory '${KRICO_CONFIG_DIR}/env' .."
  if ! mkdir -p "${KRICO_CONFIG_DIR}/env"; then
    echo ". failed"
    krico_fatal "Could not create CONFIG directory '${KRICO_CONFIG_DIR}/env'"
  fi
  echo ". ok"
fi

if [[ ${_prefix_confirmed} != 1 ]]; then
  echo -n "Saving PREFIX configuration .."
  if ! echo "${_prefix}" >"${KRICO_CONFIG_DIR}/env/PREFIX"; then
    echo ". failed"
    krico_fatal "Could not save PREFIX configuration"
  fi
  echo ". ok"
fi

if [[ ${_git_exe_confirmed} != 1 ]]; then
  echo -n "Saving GIT configuration .."
  if ! echo "${_git_exe}" >"${KRICO_CONFIG_DIR}/env/GIT_EXE"; then
    echo ". failed"
    krico_fatal "Could not save GIT configuration"
  fi
  echo ". ok"
fi

if [[ ! -d "${_prefix}" ]]; then
  echo -n "Creating directory '${_prefix}' .."
  if ! mkdir -p "${_prefix}"; then
    echo ". failed"
    krico_fatal "Could not create PREFIX directory '${_prefix}'"
  fi
  echo ". ok"
fi
_KRICO_url="git@github.com:krico/krico-sh-utils.git" # TODO: this should be configurable
echo "Bootstrapping directory '${_prefix}'"
if [[ ! -d "${_prefix}/krico-sh-utils" ]]; then
  echo "Cloning '${_KRICO_url}' into '${_prefix}/krico-sh-utils'"
  if ! cd "${_prefix}"; then krico_fatal "Failed to cd into '${_prefix}'"; fi
  if ! "${_git_exe}" clone "${_KRICO_url}"; then krico_fatal "Failed to clone '${_KRICO_url}'"; fi
else
  echo "Updating '${_prefix}/krico-sh-utils'"
  if ! cd "${_prefix}/krico-sh-utils"; then krico_fatal "Failed to cd into '${_prefix}/krico-sh-utils'"; fi
  if ! "${_git_exe}" pull; then krico_fatal "Failed to update '${_prefix}/krico-sh-utils'"; fi
fi

if [[ ! -f "${_prefix}/krico-sh-utils/bin/update.sh" || ! -x "${_prefix}/krico-sh-utils/bin/update.sh" ]]; then
  krico_fatal "Cannot execute update script '${_prefix}/krico-sh-utils/bin/update.sh'"
fi

echo "Running update script '${_prefix}/krico-sh-utils/bin/update.sh'"

if ! "${_prefix}/krico-sh-utils/bin/update.sh"; then
  krico_fatal "Update script failed"
fi

echo "Bootstrap completed!"
