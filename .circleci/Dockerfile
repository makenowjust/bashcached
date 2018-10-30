FROM ubuntu:18.10
MAINTAINER TSUYUSATO Kitsune <make.just.on@gmail.com>

RUN apt-get update && apt-get install -y \
    curl \
    git \
    locales \
    memcached \
    ruby \
    shellcheck \
    socat \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -ms /bin/bash bashcached \
 && locale-gen en_US.UTF-8

USER bashcached
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
