# krico-sh-utils: boostrap

One of the goals of `krico-sh-utils` to provide idempotent and automated creation of your
development environment.

The [bootstrap.sh](bootstrap.sh) script can be used to initialize your dev environment in a 
new computer for the first time.

Here's how you start (don't worry, the script will ask you before it does anything).
~~~bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/krico/krico-sh-utils/main/bootstrap/bootstrap.sh)"
~~~
