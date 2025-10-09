#!/usr/bin/env bash
set -e

handle_error() {
    echo "Error on line $LINENO: Command '$BASH_COMMAND' failed with exit status $?." >&2
    exit 1
}

trap handle_error ERR

if [ ! -f /dev/shm/container-started ]; then
    cd /app

    if [ ! -f /usr/local/etc/php/php.ini ]; then
        /app/docker/gen-ini.sh > /usr/local/etc/php/php.ini
    fi

    # Ensure the structure of the storage directory
    while read -r d; do
        if [ ! -d "$d" ]; then
            echo "Missing directory: $d"
            mkdir -p "$d"
        fi
    done < /app/struct.txt

    echo -n 1 > /dev/shm/container-started
fi

# Execute the passed command or fall back to the default CMD
if [ $# -eq 0 ]; then
    exec /usr/local/bin/frankenphp
else
    exec "$@"
fi
