# bashcached

> memcached built on [bash] + [socat]

[bash]: https://www.gnu.org/software/bash/
[socat]: http://www.dest-unreach.org/socat/


## Feature

It is one file script (small, <100 lines!), and it requires only:

  - `bash`
  - `socat`

So, you can use it as soon as you download it.

And, it supports multiple connections and implements almost all memcached commands:

  - `set`, `add`, `replace`, `append` and `prepend`
  - `get`, `delete` and `touch`
  - `incr` and `decr`
  - `gets` and `cas`
  - `flush_all`
  - `version` and `quit`

## Install

You could install via `brew` if you use macOS:

```console
$ brew install socat
```

Or, you could install via `apt` if you use Ubuntu:

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

USAGE: bashcached [--port=PORT] [--check=CHECK]

OPTIONS:
  --port=PORT     port to bind and listen (default: 25252)
  --check=CHECK   interval to check each cache's expire (default: 60)
$ ./bashcached &
$ telnet localhost 25252
version
VERSION 2.0.0-bashcached
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
