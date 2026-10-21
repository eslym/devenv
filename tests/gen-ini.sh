#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

actual=$(env -i PATH="$PATH" \
  PHP_INI_DISPLAY_ERRORS=On \
  PHP_INI_SESSION__UPLOAD_PROGRESS__ENABLED=1 \
  PHP_INI_MEMORY_LIMIT=512M \
  PHP_MEMORY_LIMIT=256M \
  PHP_CUSTOM_SETTING=ignored \
  PHP_UPLOAD_MAX_FILESIZE=32M \
  PHP_EMPTY= \
  bash "$script_dir/entrypoints/gen-ini.sh")

expected=$'display_errors = On\nmemory_limit = 512M\nsession.upload_progress.enabled = 1\nupload_max_filesize = 32M'

if [[ "$actual" != "$expected" ]]; then
  printf 'Unexpected output from gen-ini.sh\nExpected:\n%s\nActual:\n%s\n' \
    "$expected" "$actual" >&2
  exit 1
fi

printf 'gen-ini.sh tests passed\n'
