#!/bin/bash
set -e

# Link bun
ln -s /usr/local/bin/bun /usr/local/bin/bunx

apt update
apt -y install --no-install-recommends \
    curl \
    unzip \
    libzip-dev \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpq-dev \
    imagemagick \
    libmagickwand-dev \
    locales

sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

docker-php-ext-configure pcntl --enable-pcntl
docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp &&\
docker-php-ext-install -j$(nproc) gd pdo_mysql pdo_pgsql zip pcntl bcmath opcache

pecl install redis-${PHP_REDIS_VERSION} imagick-${IMAGICK_VERSION}
docker-php-ext-enable redis imagick

setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp

mkdir -p /app /data/caddy /config/caddy

cp -r /tmp/entrypoints /entrypoints
chmod +x /entrypoints/*

mv /entrypoints/as-web.sh /usr/local/bin/as-web
