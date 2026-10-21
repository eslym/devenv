#!/usr/bin/env bash

while IFS= read -r env_name; do
  config=${env_name#PHP_}
  config=${config,,}
  config=${config//__/\.}
  value=${!env_name}
  if [[ -n "$value" ]]; then
    echo "$config = $value"
  fi
done < <(compgen -e PHP_ | sort)
