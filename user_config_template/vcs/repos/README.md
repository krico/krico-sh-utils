## krico-sh-utils: user_config/vcs/repos ([latest version](https://github.com/krico/krico-sh-utils/blob/main/user_config_template/vcs/repos/README.md))

Version controlled repositories that should be present
in your environment.

See [README.md](https://github.com/krico/krico-sh-utils/blob/main/user_config_template/vcs/repos/README.md) for
the latest supported format.

Create a file in this directory for each version controlled
repository you would like to be checked out (aka cloned).  
Subdirectories are supported if you want to organize it like that.

When you add new files, just run `krico-sh-utils/bin/update.sh` to apply.

### Format

This file is _sourced_ as a bash script, therefore:

- Empty lines and lines starting with `#` are ignored.
- Each non-ignored lined should be of the form `<property-name>=<value>`

**Supported properties**

For example, a file `vcs/repos/example`

~~~shell
# hidden=[0|1] (optional, default: 0)
# 1 - Hide (disable) a repository so it is not checked out
# 0 - Checkout this repository
hidden=1

# name=<dir-name> (optional, default: filename aka "example")
# local name (or directory name) that the repository should have
name=my-example

# url=<repository_url> (required)
# Url of the repository to checkout
url=git@github.com:krico/example.git

# upstream_url=<upstream_url> (optional, default: ${url})
# For example if this repo is a fork, configure the upstream remote
upstream_url=git@github.com:krico/example.git

# owner=<owner-name> (optional, default: extracted from url)
# The organization or user that owns this repository
owner=krico

~~~

This configuration would clone `git@github.com:krico/example.git`
into `PREFIX/Github/krico/my-example` (if it wasn't disabled), because:

- `github.com` has `Github` alias defined in [server_aliases](../server_aliases)
- The `owner` of the repository is `krico`
- `my-example` is defined as the name
