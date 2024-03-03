# +====================================================================================================
# | krico-sh-utils: bin/init.bash
# |
# | Initialize the krico-sh-utils bash environment
# |
# | Loaded modules:
# |   - import
# |   - env
# +====================================================================================================
export KRICO_CONFIG="${HOME}/.krico-sh-utils"
if [[ ! -r "${KRICO_CONFIG}/env/PREFIX" ]]; then
  echo "ERROR: init.bash: '${KRICO_CONFIG}/env/PREFIX' missing" >&2
  return 1
fi

export KRICO_PREFIX="$(head -1 "${HOME}/.krico-sh-utils/env/PREFIX")"
if [[ -z "${KRICO_PREFIX}" || ! -d "${KRICO_PREFIX}/krico-sh-utils/lib" ]]; then
  echo "ERROR: init.bash: KRICO_PREFIX='${KRICO_PREFIX}' is invalid" >&2
  return 1
fi

export KRICO_SH_UTILS="${KRICO_PREFIX}/krico-sh-utils"
export KRICO_LIB="${KRICO_SH_UTILS}/lib"
export KRICO_BIN="${KRICO_SH_UTILS}/bin"

if ! source "${KRICO_LIB}/import.bash"; then
  echo "ERROR: init.bash: Failed to load '${KRICO_LIB}/import.bash'" >&2
  return 1
fi

import "env" || return 1
