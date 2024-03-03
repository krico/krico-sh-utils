#!/usr/bin/env bash
# +====================================================================================================
# | krico-sh-utils: bin/update.sh
# |
# | Idempotent installation of your krico-sh-utils development environment
# +====================================================================================================
if ! source "$(dirname "$0")/../lib/init.bash"; then
  echo "Failed to initialize the environment: $!" >&2
  exit 1
fi

import "log" || exit 1
import "git" || exit 1

krico_info "Updating krico-sh-utils installation [PREFIX=${KRICO_PREFIX}]"
krico_debug "Pulling changes from krico-sh-utils using git '${KRICO_GIT}'"
git_pull "${KRICO_SH_UTILS}" || exit 1
exit 0
