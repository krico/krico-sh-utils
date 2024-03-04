# +====================================================================================================
# | krico-sh-utils: lib/update/get_code.bash
# |
# | Fetches repositories defined in user_config/vcs/repos
# +====================================================================================================

function get_code() {
  krico_info "${FUNCNAME[0]}: started"
  if [[ -z "${KRICO_USER_CONFIG}" || ! -d "${KRICO_USER_CONFIG}" ]]; then
    echo "${FUNCNAME[0]}: KRICO_USER_CONFIG '${KRICO_USER_CONFIG}' must be defined and point to a directory" >&2
    return 1
  fi

  local repos_dir="${KRICO_USER_CONFIG}/vcs/repos"
  if [[ ! -d "${repos_dir}" || ! -r "${repos_dir}" ]]; then
    krico_warn "${FUNCNAME[0]}: repos_dir '${repos_dir}' is not a readable directory"
    return 0 # Not a failure, just nothing the checkout
  fi

  local tmp=$(mktemp -t "${FUNCNAME[0]}")
  local fd=$(krico_find_fd)
  find "${repos_dir}" -type f >"${tmp}"
  eval "exec ${fd}<'${tmp}'"
  local file
  while IFS=$'\n' read -u ${fd} file; do
    local file_name="$(basename "${file}")"

    if [[ "${file_name}" == "README.md" ]]; then continue; fi

    if ! get_code_repo "${file}"; then
      eval "exec ${fd}>&-"
      rm -f "${tmp}"
      return 1
    fi
  done

  eval "exec ${fd}>&-"
  rm -f "${tmp}"
  krico_info "${FUNCNAME[0]}: success"
}

function get_server_alias() {
  local server_name="$1"
  local server_aliases="${KRICO_USER_CONFIG}/vcs/server_aliases"
  if [[ -r "${server_aliases}" ]]; then
    local fd=$(krico_find_fd)
    eval "exec ${fd}<'${server_aliases}'"
    local line
    while IFS=$'\n' read -u ${fd} line; do
      if [[ $line =~ ^# ]]; then continue; fi
      if [[ $line =~ ^\s+$ ]]; then continue; fi
      if [[ $line =~ ^([^,]+),(.*)$ ]]; then
        local alias="${BASH_REMATCH[1]}"
        local server="${BASH_REMATCH[2]}"
        if [[ $server == "$server_name" ]]; then
          echo "$alias"
          eval "exec ${fd}>&-"
          return 0
        fi
      fi
    done
    eval "exec ${fd}>&-"
  fi
  echo "$server_name"
}

function get_code_repo() {
  local file="$1"
  local file_name="$(basename "$file")"

  local name="${file_name}"
  local hidden=0
  local url
  local upstream_url
  local owner
  local extracted_server
  local server_alias
  local extracted_owner
  local extracted_repo

  if ! source "${file}"; then
    krico_error "Reading '${file}' failed: $!"
    return 1
  fi

  if [[ -z "${url}" ]]; then
    krico_error "${FUNCNAME[0]}: file_name='${file_name}' missing required field 'url'"
    return 1
  fi

  if [[ -z "${name}" ]]; then
    name="${file_name}"
  fi

  if [[ -z "${upstream_url}" ]]; then
    upstream_url="${url}"
  fi

  if [[ $url =~ ^https://([^/]+)/([^/]+)/([^/]+).git$ ||
    $url =~ ^git@([^\:]+):([^/]+)/([^/]+).git$ ]]; then
    extracted_server="${BASH_REMATCH[1]}"
    extracted_owner="${BASH_REMATCH[2]}"
    extracted_repo="${BASH_REMATCH[3]}"
    server_alias="$(get_server_alias "${extracted_server}")"
    if [[ -z "${owner}" ]]; then owner="${extracted_owner}"; fi
    krico_trace "${FUNCNAME[0]}: url='${url}': [server=$extracted_server][alias=${server_alias}][owner=$extracted_owner][repo=${extracted_repo}]"
  else
    krico_error "${FUNCNAME[0]}: url='${url}' did not match any pattern"
    return 1
  fi

  if [[ "$hidden" == "1" ]]; then
    krico_info "Ignored hidden repo [file_name=${file_name}][name=$name][url=$url]"
    return 0
  fi

  local dir="${KRICO_PREFIX}/${server_alias}/${owner}/${name}"
  if [[ -d "${dir}" ]]; then
    krico_debug "${FUNCNAME[0]}: repository already exists '${dir}'"
  else
    krico_debug "${FUNCNAME[0]}: cloning '${url}' to '${dir}'"
    if ! git clone "${url}" "${dir}"; then
      krico_error "${FUNCNAME[0]}: git clone '${url}' failed: $!"
      return 1
    fi
    git -C "${dir}" remote add upstream "${upstream_url}"
  fi
}
