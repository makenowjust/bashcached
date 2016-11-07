# bashcached

> memcached built on [bash] + [socat]

[bash]: https://www.gnu.org/software/bash/
[socat]: http://www.dest-unreach.org/socat/


## Feature

It is one file script (small, <100 lines!), and it requires only:

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

And, it supports to serve over `tcp`, `udp` and `unix` domain socket.


## Install

You could install `socat` via `brew` if you use macOS:

```console
$ brew install socat
```

Or, you could install `socat` via `apt` if you use Ubuntu:

```console
$ sudo apt install socat
```

then, download and chmod.

```console
$ curl -LO https://raw.githubusercontent.com/MakeNowJust/bashcached/master/bashcached
$ chmod +x bashcached
```


## Usage

```console
$ ./bashcached --help
bashcached - memcached built on bash + socat
(C) TSUYUSATO "MakeNowJust" Kitsune 2016 <make.just.on@gmail.com>

USAGE: bashcached [--help] [--version] [--protocol=tcp|udp|unix] [--address=ADDRESS] [--check=CHECK]

OPTIONS:
  --protocol=tcp|udp|unix  protocol name to bind and listen (default: tcp)
  --address=ADDRESS        address (or filename) to bind and listen (default: 25252)
  --check=CHECK            interval to check each cache's expire (default: 60)
  --help                   show this help
  --version                show bashcached's version
$ ./bashcached &
$ telnet localhost 25252
version
VERSION 3.1.0-bashcached
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
© TSUYUSATO "[MakeNowJust](https://quine.codes)" Kitsune <<make.just.on@gmail.com>> 2016
