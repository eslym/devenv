#!/usr/bin/env bash

declare -A values=()
declare -A configured=()

# Keep PHP_* as a backward-compatible alias, but prefer PHP_INI_* when both
# names refer to the same ini setting.
while IFS= read -r env_name; do
  [[ "$env_name" == PHP_INI_* ]] && continue
  case "$env_name" in
    PHP_UPLOAD_MAX_FILESIZE|PHP_MAX_FILE_UPLOADS|PHP_POST_MAX_SIZE|\
    PHP_ERROR_REPORTING|PHP_DISPLAY_ERRORS|PHP_MAX_EXECUTION_TIME|\
    PHP_MEMORY_LIMIT) ;;
    *) continue ;;
  esac
  config=${env_name#PHP_}
  config=${config,,}
  config=${config//__/\.}
  values[$config]=${!env_name}
  configured[$config]=1
done < <(compgen -e PHP_ | sort)

while IFS= read -r env_name; do
  config=${env_name#PHP_INI_}
  config=${config,,}
  config=${config//__/\.}
  values[$config]=${!env_name}
  configured[$config]=1
done < <(compgen -e PHP_INI_ | sort)

while IFS= read -r config; do
  value=${values[$config]}
  if [[ -n "$value" ]]; then
    echo "$config = $value"
  fi
done < <(printf '%s\n' "${!configured[@]}" | sort)
