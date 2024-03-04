# +====================================================================================================
# | krico-sh-utils: lib/update/user_config.bash
# |
# | Handles creation and update of the user-specific configuration repository
# +====================================================================================================

function _user_config_wizard() {
  echo
  echo "+++ Create user specific configuration repository +++"
  echo
  echo "krico-sh-utils uses a git repository to store your user's specific configurations"
  echo
  while [[ 1 ]]; do
    echo "Here are your options:"
    echo
    echo " [new  ]  create your user's repository from a template"
    echo " [clone]  clone your user's repository from a url"
    echo " [quit ]  abort"
    echo
    read -p "Make your choice (new|clone|quit): " _choice
    case "${_choice}" in
    n | new | N | New | NEW)
      if _user_config_new; then return 0; else return 1; fi
      ;;
    c | clone | C | Clone | CLONE)
      if _user_config_clone; then return 0; else return 1; fi
      ;;
    q | quit | Q | Quit | QUIT)
      return 1
      ;;
    *)
      echo
      echo "invalid choice '${_choice}'"
      echo
      sleep 1
      ;;
    esac
  done
}

function _user_config_new() {
  local repo_name
  local repo_path
  if [[ -n "${USER}" ]]; then
    repo_name="krico-sh-utils-config-${USER}"
  else
    repo_name="krico-sh-utils-config-$(id -un)"
  fi
  while [[ 1 ]]; do
    read -p "Please enter the name of your user config repository (${repo_name}): " _choice

    if [[ -n "${_choice}" ]]; then
      repo_name=${_choice}
    fi

    repo_path="${KRICO_PREFIX}/${repo_name}"
    if [[ -d "${repo_path}" ]]; then
      echo "SORRY: A directory named '${repo_name}' already exists (${repo_path})"
      continue
    fi

    read -p "Create repository '${repo_name}' as '${repo_path}'? (y/n): " _choice
    case "${_choice}" in
    y | Y | yes | Yes) break ;;
    *)
      echo "Let's try again then..."
      ;;
    esac
  done

  cp -a "${KRICO_SH_UTILS}/user_config_template" "${repo_path}"
  git -C "${repo_path}" init
  git -C "${repo_path}" add --all
  git -C "${repo_path}" commit -m "User specific configuration created from template"
  krico_env_set USER_CONFIG "${repo_path}"

  echo "+++ User specific configuration created +++"
  echo
  echo "You can manage your user-specific configurations which are stored in"
  echo "${repo_path}"
  echo
  echo "krico-sh-utils does NOT pull, commit or modify that directory (that's your job)"
  echo "krico-sh-utils reads configurations that dictate how the environment is setup"
  echo
  echo "It is strongly recommended that you read the README.md file in that directory before you continue"
  echo ""
  read -p "I have read and understand (yes/quit): " _choice
  case "${_choice}" in
  y | Y | yes | Yes) break ;;
  *)
    echo "You can run the bootstrap or update process again to pick up where you started"
    return 1
    ;;
  esac
  return 0
}

function _user_config_clone() {
  local repo_url
  local repo_name
  local repo_path
  while [[ 1 ]]; do
    read -p "Please enter the git URL of your user config repository: " _choice
    if [[ -n "${_choice}" ]]; then
      repo_name="$(basename "${_choice}" .git)"
      repo_path="${KRICO_PREFIX}/${repo_name}"
      echo "Repository name: ${repo_name}"
      echo "Repository path: ${repo_path}"
      echo "Repository url : ${_choice}"
      read -p "OK to proceed? (yes/no): " _yesNo
      case "${_yesNo}" in
      y | Y | yes | Yes)
        repo_url="${_choice}"
        break
        ;;
      *)
        continue
        ;;
      esac
    fi
  done
  git -C "${KRICO_PREFIX}" clone "${repo_url}"
  krico_env_set USER_CONFIG "${repo_path}"
  return 0
}

function user_config_check() {
  krico_info "Checking user specific configuration repository"
  local user_config="$(krico_env_get USER_CONFIG)"
  if [[ -z "${user_config}" ]]; then

    if ! _user_config_wizard; then return 1; fi
  else
    if [[ ! -d "${user_config}" ]]; then
      echo "ERROR: user_config.bash: USER_CONFIG directory '${user_config}' doesn't exist" >&2
      return 1
    fi
  fi

  export KRICO_USER_CONFIG="$(krico_env_get USER_CONFIG)"
  krico_info "Found user specific configuration repository '${KRICO_USER_CONFIG}'"
}
