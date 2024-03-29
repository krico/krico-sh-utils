# krico-sh-utils: user_config ([latest version](https://github.com/krico/krico-sh-utils/blob/main/user_config_template/README.md))

User specific configurations for [krico-sh-utils](https://github.com/krico/krico-sh-utils).

It was initialized as a copy `krico-sh-utils/user_config_template` and can
be modified to fit a user's need.

Please refer to
[krico-sh-utils/user_config_template](https://github.com/krico/krico-sh-utils/tree/main/user_config_template)
for latest version.

## User specific configuration

Here a list of user specific configurations

### [initrc](./initrc)

File source as part of the initialization of your interactive shell

### [gitconfig/](./gitconfig)

Contains "gitconfig" files like the ones used by git.

They are applied every time you update krico-sh-utils (eg. `bootsrap/bootsrap.sh` or `bin/update.sh`).
It only adds (or overwrites) config values, doesn't delete existing ones.

- `gitconfig/global` is applied to your user's global gitconfig
- `gitconfig/repo.${repo_name}` (if present) is applied to repository named `${repo_name}`
- `gitconfig/repo` is applied to a repository if `repo.${repo_name}` doesn't exit

### [lib/](./lib)

Contains user modules that enrich your shell environment

### [vcs/](./vcs)

Configurations related to version control systems in general

- [vcs/server_aliases](vcs/server_aliases) list of server aliases, format `<alias-name>,<server-name>`.
  Example `Github,github.com`.
  will cause a repository `https://github.com/nodejs/node` to be checked out into `Github/nodejs/node`
- [vcs/repos](vcs/repos) contains the version controlled repositories that should be checked out in your repository