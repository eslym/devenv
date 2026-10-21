# eslym/php

`eslym/php` is a PHP development and application container built on
[FrankenPHP](https://frankenphp.dev/). It includes Composer, common PHP
extensions, and helper entrypoints for running PHP commands and Laravel apps.

## Images and build targets

The Dockerfile defines three stages:

- `base` — FrankenPHP runtime with Composer, PHP extensions, and the container
  entrypoints.
- `devenv` — `base` plus development tools, Node.js, Bun, and a non-root
  `devenv` user (UID 1000). This is the normal development image.
- `wsl` — `devenv` plus systemd configuration for use with WSL. This is the
  Dockerfile's final/default stage.

Build the development image locally with:

```sh
docker build --target devenv -t eslym/php:devenv .
```

To build the WSL image instead:

```sh
docker build --target wsl -t eslym/php:wsl .
```

Build arguments in `Dockerfile` select the FrankenPHP, PHP, Composer, Bun,
Stacker, regctl, Redis extension, and Imagick extension versions.

## Running

Mount your project at `/app` and pass any command after the image name to run
it instead of starting FrankenPHP:

```sh
docker run --rm -it \
  -v "$PWD:/app" \
  -p 80:80 -p 443:443 \
  eslym/php:devenv
```

The `devenv` stage runs as the `devenv` user by default. The base image's
FrankenPHP process is the default command. To run a one-off PHP command:

```sh
docker run --rm -v "$PWD:/app" eslym/php:devenv php -v
```

The runtime creates `/app`, `/data/caddy`, and `/config/caddy`. For persistent
FrankenPHP/Caddy state, mount the latter two paths as volumes.

## PHP configuration

On first container startup, the PHP and Laravel entrypoints generate
`/usr/local/etc/php/php.ini` from non-empty environment variables prefixed with
`PHP_`. Variable names are converted to lowercase; double underscores become
dots. For example:

```sh
docker run --rm \
  -e PHP_MEMORY_LIMIT=512M \
  -e PHP_SESSION__UPLOAD_PROGRESS__ENABLED=1 \
  eslym/php:devenv
```

produces these ini settings:

```ini
memory_limit = 512M
session.upload_progress.enabled = 1
```

The generated ini file is only created when it does not already exist, so a
mounted or otherwise pre-created file takes precedence.

## Entrypoints

- `php` performs first-start initialization (including creating directories
  listed in `/app/struct.txt`) and then starts FrankenPHP or executes the
  supplied command.
- `laravel` does the same initialization for a Laravel application, generates
  an `APP_KEY` when needed, fixes ownership of `storage`, and runs
  `php artisan optimize` unless `LARAVEL_NO_OPTIMIZE=true`.
- `as-web` runs its arguments as `www-data`.

## Included tools and extensions

The base image installs the PHP extensions `gd`, `pdo_mysql`, `pdo_pgsql`,
`zip`, `pcntl`, `bcmath`, Redis, and Imagick. OPcache is enabled for PHP
versions earlier than 8.5 (it is built into PHP 8.5 and later). The development
stage also includes Xdebug, Git, MariaDB and Redis clients, Node.js, Bun,
`stacker`, and `regctl`.

## Tests

Run the standalone test for PHP environment-variable-to-ini conversion with:

```sh
bash tests/gen-ini.sh
```
