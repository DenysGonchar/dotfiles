#!/usr/bin/env bash

## this script is based on this article:
##     https://grahamwatts.co.uk/macos-secrets/

## enable strict mode
set -euo pipefail

readonly KIND="shell secret"
readonly DEFAULT_ACCOUNT="${USER:-default}"

##-------------------------------------------------------
## helper functions
##-------------------------------------------------------

print_help() {
  cat <<'EOF'
Supported subcommands:
  new service [account]     - creates a new secret (fails if it already exists)
  get service [account]     - prints a stored secret to stdout
  update service [account]  - updates a secret (creates it if missing)
  delete service [account]  - removes a secret
  list                      - launches the Keychain Access app; use the 'shell secret'
                              filter to show only the secrets added by this script
  help                      - shows this help
EOF
}

# check_number_of_args <actual> <min> [max]  (max defaults to min)
check_number_of_args() {
  local actual="$1"
  local min="$2"
  local max="${3:-$min}"
  if [ "$actual" -lt "$min" ] || [ "$actual" -gt "$max" ]; then
    echo "ERROR: invalid arguments" >&2
    print_help >&2
    return 1
  fi
}

# read_secret <varname>: prompts silently, validates, stores the result in <varname>
read_secret() {
  local varname="$1"
  local value=""
  if IFS= read -r -s -p "Enter your secret: " value; then
    echo >&2 ## just an empty line after read
    if [ -z "$value" ]; then
      echo "ERROR: empty secret" >&2
      return 1
    fi
  else
    echo -e "\nERROR: aborted" >&2
    return 1
  fi
  printf -v "$varname" '%s' "$value"
}

is_valid_function() {
  local function_name="$1"
  declare -F "$function_name" > /dev/null
}

run_subcommand() {
  local subcommand="${1:-help}"
  if [ "$#" -gt 0 ]; then
    shift 1
  fi

  local fn="secrets__${subcommand}"

  if is_valid_function "$fn"; then
    "$fn" "$@"
  else
    echo "ERROR: unknown subcommand: '${subcommand}'" >&2
    print_help >&2
    return 1
  fi
}

##-------------------------------------------------------
## subcommand functions
##-------------------------------------------------------

secrets__new() {
  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  local secret=""
  read_secret secret || return 1
  security add-generic-password -a "$account" -s "$service" -D "$KIND" -w "$secret"
}

secrets__get() {
  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  security find-generic-password -a "$account" -s "$service" -D "$KIND" -w
}

secrets__update() {
  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  local secret=""
  read_secret secret || return 1
  security add-generic-password -a "$account" -s "$service" -D "$KIND" -w "$secret" -U
}

secrets__delete() {
  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  security delete-generic-password -a "$account" -s "$service" -D "$KIND"
}

secrets__list() {
  check_number_of_args "$#" 0 || return 1
  echo "use the '${KIND}' filter to show only the secrets added by this script" >&2
  open -a "Keychain Access"
}

secrets__help() {
  check_number_of_args "$#" 0 || return 1
  print_help
}

##-------------------------------------------------------

run_subcommand "$@"
