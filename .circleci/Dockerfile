FROM ubuntu:17.10
MAINTAINER TSUYUSATO Kitsune <make.just.on@gmail.com>

RUN apt-get update && apt-get install -y \
    git \
    shellcheck \
    ruby \
    socat \
    memcached \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -ms /bin/bash bashcached

USER bashcached
