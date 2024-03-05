## krico-sh-utils: user_config/lib

You can create your own modules under this `user_config/lib/` directory

### Usage

If you create a file named `greeting.bash` in this directory

File: `greeting.bash`
~~~shell
function say_hi() {
  echo "HI"
}

function say_hello() {
  echo "Hello"
}
~~~

You can then use this new module like so:
~~~shell
import "greeting" || exit 1

say_hi
say_hello
~~~
