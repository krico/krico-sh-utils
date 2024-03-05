#!/usr/bin/env bash
# +====================================================================================================
# | krico-sh-utils: bin/update.sh
# |
# | Idempotent installation of your krico-sh-utils development environment
# +====================================================================================================
if ! source "$(dirname "$0")/../lib/update/init_update.bash"; then
  echo "Failed to initialize the environment for update: $!" >&2
  exit 1
fi

import "log" || exit 1
import "git" || exit 1

krico_info "Updating krico-sh-utils installation [PREFIX=${KRICO_PREFIX}]"
krico_info "git pull krico-sh-utils"
git_pull "${KRICO_SH_UTILS}" || exit 1

import "update/user_config" || exit 1
import "update/get_code" || exit 1

user_config_check || exit 1
git_config_global || exit 1
get_code || exit 1

exit 0
