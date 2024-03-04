# krico-sh-utils: user_config

User specific configurations for [krico-sh-utils](https://github.com/krico/krico-sh-utils).

It was initialized as a copy `krico-sh-utils/user_config_template` and can
be modified to fit a user's need.

Please refer to
[krico-sh-utils/user_config_template](https://github.com/krico/krico-sh-utils/tree/main/user_config_template)
for latest version.

## User specific configuration

Here a list of user specific configurations

### gitconfig/

Contains "gitconfig" files like the ones used by git.

They are applied every time you update krico-sh-utils (eg. `bootsrap/bootsrap.sh` or `bin/update.sh`).
It only adds (or overwrites) config values, doesn't delete existing ones.

- `gitconfig/global` is applied to your user's global gitconfig
- `gitconfig/repo.${repo_name}` (if present) is applied to repository named `${repo_name}`
- `gitconfig/repo` is applied to a repository if `repo.${repo_name}` doesn't exit

### vcs/

Configurations related to version control systems in general

- `vcs/server_aliases` list of server aliases, format `<alias-name>,<server-name>`.  Example `Github,github.com`.
will cause a repository `https://github.com/nodejs/node` to be checked out into `Github/nodejs/node`