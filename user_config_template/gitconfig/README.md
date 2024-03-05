## krico-sh-utils: user_config/gitconfig ([latest version](https://github.com/krico/krico-sh-utils/tree/main/user_config_template/gitconfig))

The krico-sh-utils *bootstrap/update* procedure applies git configurations
based on files present in this directory.

The format of these files is the same as described in [git config](https://git-scm.com/docs/git-config#EXAMPLES).

The *bootstrap/update* procedure looks for files in this directory and applies (add only)
each config value to your environment as follows:

1. If a file named `global` exists, every config value is added to git's **global** configuration
2. When cloning a repository named `foo` if a file named `repo.foo` exists it is applied to the repository
3. If `repo.foo` doesn't exist but a file named `repo` exists, that one is applied to the repository

