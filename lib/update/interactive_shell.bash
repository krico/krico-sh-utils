# +====================================================================================================
# | krico-sh-utils: lib/update/interactive_shell.bash
# |
# | Configure the interactive shell if necessary
# +====================================================================================================

function interactive_shell_check() {
  local initrc="${KRICO_CONFIG}/initrc"
  if [[ -f "${initrc}" ]]; then
    krico_info "${FUNCNAME[0]}: Interactive shell initrc already installed in '${initrc}'"
    return 0
  fi
  local src="${KRICO_SH_UTILS}/bootstrap/initrc"
  if [[ ! -r "${src}" ]]; then
    krico_error "${FUNCNAME[0]}: Cannot find '${src}'"
    return 1
  fi
  interactive_shell_wizard "${src}" "${initrc}"
}

function interactive_shell_wizard() {
  local source="$1"
  local target="$2"
  local profile="${HOME}/.profile"
  local bashrc="${HOME}/.bashrc"
  krico_trace "${FUNCNAME[0]}: Installing '${source}' to '${target}'"

  for p in "${HOME}/.bash_profile" "${HOME}/.bash_login" "${HOME}/.profile"; do
    if [[ -f "${p}" ]]; then
      profile="${p}"
      break
    fi
  done

  echo
  echo "+++ Configure interactive shell +++"
  echo
  echo "krico-sh-utils can be added to your interactive shell by adding some commands"
  echo " to the shell's initialization files (.bashrc, .bash_profile, etc)."
  echo
  echo "By selecting 'yes' to the next question, we will walk you through the process of doing this..."
  echo

  while [[ 1 ]]; do
    read -p "Would you like to add krico-sh-utils into your interactive shell? (yes/no): " _choice
    case "${_choice}" in
    y | Y | yes | Yes)
      if interactive_shell_install "${profile}" "${bashrc}"; then
        return 0
      else
        return 1
      fi
      ;;
    n | N | no | No)
      if ! cp -a "${source}" "${target}"; then
        echo "${FUNCNAME[0]}: failed to copy '${source}' to '${target}': $!"
        return 1
      fi
      interactive_shell_explain_manual_add "${profile}" "${bashrc}"
      return 0
      ;;
    *)
      echo "Invalid choice '${_choice}'"
      ;;

    esac
  done
}

function interactive_shell_explain_manual_add() {
  local profile="$1"
  local bashrc="$2"
  echo
  echo "You can add krico-sh-utils to your interactive shell later:"
  echo
  echo "Add the following line"
  echo
  echo "    if [[ -r ~/.krico-sh-utils/initrc ]]; then source ~/.krico-sh-utils/initrc; fi"
  echo
  echo "- To '${profile}' to add krico-sh-utils to the login shell"
  echo "- To '${bashrc}' to add krico-sh-utils to non-login shell"
  echo
  echo "To run this wizard again, remove '${KRICO_CONFIG}/initrc' and run ${KRICO_SH_UTILS}/bin/update.sh"
  echo
}

function interactive_shell_install() {
  local profile="$1"
  local bashrc="$2"
  local added=0

  echo
  echo "To add krico-sh-utils to your interactive shell, just add the following line:"
  echo
  echo "    if [[ -r ~/.krico-sh-utils/initrc ]]; then source ~/.krico-sh-utils/initrc; fi"
  echo
  echo "to your profile."
  echo
  echo "This script can do that for you \o/"
  echo

  if ! cp -a "${source}" "${target}"; then
    echo "${FUNCNAME[0]}: failed to copy '${source}' to '${target}': $!"
    return 1
  fi

  while [[ 1 ]]; do
    read -p "Would you to add krico-sh-utils to your login shell '${profile}'? (yes/no): " _choice
    case "${_choice}" in
    y | Y | yes | Yes)
      echo '# Line added by krico-sh-utils bootstrap' >>"${profile}"
      echo 'if [[ -r ~/.krico-sh-utils/initrc ]]; then source ~/.krico-sh-utils/initrc; fi' >>"${profile}"
      echo "krico-sh-utils added to '${profile}'"
      added=1
      break
      ;;
    n | N | no | No)
      break
      ;;
    *)
      echo "Invalid choice '${_choice}'"
      ;;
    esac
  done

  while [[ 1 ]]; do
    read -p "Would you to add krico-sh-utils to non-login shell '${bashrc}'? (yes/no): " _choice
    case "${_choice}" in
    y | Y | yes | Yes)
      echo '# Line added by krico-sh-utils bootstrap' >>"${bashrc}"
      echo 'if [[ -r ~/.krico-sh-utils/initrc ]]; then source ~/.krico-sh-utils/initrc; fi' >>"${bashrc}"
      echo "krico-sh-utils added to '${bashrc}'"
      added=1
      break
      ;;
    n | N | no | No)
      break
      ;;
    *)
      echo "Invalid choice '${_choice}'"
      ;;
    esac
  done
  if [[ $added == 0 ]]; then
    interactive_shell_explain_manual_add
  fi
}
