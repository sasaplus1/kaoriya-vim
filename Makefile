.DEFAULT_GOAL := all

SHELL := /bin/bash

export DOCKER_BUILDKIT := 1

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

configurations := $(strip \
  --enable-fail-if-missing \
  --disable-smack \
  --disable-selinux \
  --disable-xsmp \
  --disable-xsmp-interact \
  --enable-luainterp=dynamic \
  --enable-pythoninterp=dynamic \
  --enable-python3interp=dynamic \
  --enable-cscope \
  --disable-netbeans \
  --enable-terminal \
  --enable-multibyte \
  --disable-rightleft \
  --disable-arabic \
  --enable-gui=no \
  --with-compiledby=sasa+1 \
  --with-features=huge \
  --with-luajit \
  --without-x \
  --with-tlib=ncurses \
)

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: build
build: image := ubuntu:latest
build: setup := $(strip \
  DEBIAN_FRONTEND=noninteractive \
  apt --yes update && \
  DEBIAN_FRONTEND=noninteractive \
  apt --yes install \
  autoconf git make \
  build-essential libncurses-dev \
  gettext \
  lua5.1 liblua5.1-dev luajit libluajit-5.1-dev \
  python python-dev \
  python3 python3-dev && \
  apt-get --yes clean && \
  rm -rf /var/lib/apt/lists/* \
)
build: arguments := -t sasaplus1/kaoriya-vim
build: arguments += --build-arg 'configurations=$(configurations)'
build: arguments += --build-arg 'image=$(image)'
build: arguments += --build-arg 'setup=$(setup)'
build: ## build deb package
	docker image prune --force
	docker build $(arguments) .
