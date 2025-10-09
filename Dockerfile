ARG FRANKENPHP_VERSION=1.9.1
ARG PHP_VERSION=8.4.13
ARG COMPOSER_VERSION=2.8.12
ARG BUN_VERSION=1.2.23
ARG STACKER_VERSION=1.1.3

ARG REGCLIENT_VERSION=0.9.1

FROM composer:${COMPOSER_VERSION} AS composer
FROM oven/bun:${BUN_VERSION}-debian AS bun
FROM eslym/stacker:${STACKER_VERSION} AS stacker
FROM regclient/regctl:v${REGCLIENT_VERSION} AS regctl

# ========================================================== #
#  Base Build Stage
# ========================================================== #
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION} AS base

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

ARG PHP_REDIS_VERSION=6.2.0
ARG IMAGICK_VERSION=3.8.0

RUN --mount=type=bind,source=./scripts/php-base.sh,target=/tmp/scripts/php-base.sh,ro \
    --mount=type=bind,source=./entrypoints,target=/tmp/entrypoints,ro \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    bash /tmp/scripts/php-base.sh

# ========================================================== #
#  Devcontainer Build Stage
# ========================================================== #
FROM base AS devenv

COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
COPY --from=stacker /usr/local/bin /usr/local/bin
COPY --from=regctl /regctl /usr/local/bin/regctl

RUN --mount=type=bind,source=./scripts/devenv.sh,target=/tmp/scripts/devenv.sh,ro \
    --mount=type=bind,source=./scripts/bashrc,target=/tmp/scripts/bashrc,ro \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    bash /tmp/scripts/devenv.sh

ENV XDG_DATA_HOME=/home/devenv/.local/share
ENV XDG_CONFIG_HOME=/home/devenv/.config
ENV XDG_CACHE_HOME=/home/devenv/.cache

USER devenv

# ========================================================== #
#  Image for export to WSL
# ========================================================== #
FROM devenv AS wsl

RUN --mount=type=bind,source=./scripts/,target=/tmp/scripts,ro \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    sudo bash /tmp/scripts/wsl.sh
