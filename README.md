# bashcached

> memcached server built on [bash] + [socat]

[bash]: https://www.gnu.org/software/bash/
[socat]: http://www.dest-unreach.org/socat/

[![CircleCI](https://circleci.com/gh/MakeNowJust/bashcached.svg?style=svg)](https://circleci.com/gh/MakeNowJust/bashcached)

## Feature

It is one file script (small, `(($(< bashcached wc -l) < 100))`!), and it requires only:

  - `bash`
  - `socat`

So, you can use it as soon as you download it.

It supports multiple connections and implements almost all memcached commands:

  - `set`, `add`, `replace`, `append` and `prepend`
  - `get`, `delete` and `touch`
  - `incr` and `decr`
  - `gets` and `cas`
  - `flush_all`
  - `version` and `quit`

And, it supports to serve over `tcp` and `unix` domain socket.

## Install

You could install `base64`, `bash` and `socat` via `brew` if you use macOS:

```console
$ brew install base64 bash socat
```

(In fact, `bash` is installed in the default, however it is *too old* to run `bashcached`.)

Or, you could install `socat` via `apt` if you use Ubuntu:

```console
$ sudo apt install socat
```

then, download and chmod.

```console
$ curl -LO https://git.io/bashcached
$ chmod +x bashcached
```

## Usage

```console
$ ./bashcached --help
bashcached - memcached built on bash + socat
(C) TSUYUSATO "MakeNowJust" Kitsune 2017 <make.just.on@gmail.com>

USAGE: bashcached [--help] [--version] [--protocol=tcp|unix] [--port=PORT] [--check=CHECK]

OPTIONS:
  --protocol=tcp|unix      protocol name to bind and listen (default: tcp)
  --port=PORT              port (or filename) to bind and listen (default: 25252)
  --check=CHECK            interval to check each cache's expire (default: 60)
  --help                   show this help
  --version                show bashcached's version
$ ./bashcached &
$ telnet localhost 25252
version
VERSION 5.1.2-bashcached
set hello 0 0 11
hello world
STORED
get hello
VALUE hello 0 11
hello world
END
quit
```

## License and Copyright

MIT and [:sushi:](https://github.com/MakeNowJust/sushi-ware)
© TSUYUSATO "[MakeNowJust](https://quine.codes)" Kitsune <<make.just.on@gmail.com>> 2016-2018
