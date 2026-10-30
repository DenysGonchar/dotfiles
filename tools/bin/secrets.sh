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
  new [--value secret] service [account]
                            - creates a new secret (fails if it already exists)
  get service [account]     - prints a stored secret to stdout
  update [--value secret] service [account]
                            - updates a secret (creates it if missing)
  delete service [account]  - removes a secret
  list                      - launches the Keychain Access app; use the 'shell secret'
                              filter to show only the secrets added by this script
  help                      - shows this help

If --value is omitted, the secret is read from an interactive silent prompt.
Note: a value passed with --value is visible in shell history and process lists.
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

# check_names <service> <account>: rejects names that start with '-' (they look like options)
check_names() {
  local service="$1"
  local account="$2"
  if [[ "$service" == -* ]] || [[ "$account" == -* ]]; then
    echo "ERROR: service and account names must not start with '-'" >&2
    return 1
  fi
}

# parse_value_option <value_varname> <consumed_varname> [args...]
# if the args start with '--value <secret>', stores the secret in <value_varname>;
# stores the number of consumed args (0 or 2) in <consumed_varname>
# note: locals use a '__' prefix so they can't shadow the caller's variables
# that are passed in by name (printf -v writes to the nearest scope)
parse_value_option() {
  local __value_varname="$1"
  local __consumed_varname="$2"
  shift 2

  local __value=""
  local __consumed=0

  if [ "${1:-}" = "--value" ]; then
    if [ "$#" -lt 2 ]; then
      echo "ERROR: --value requires an argument" >&2
      print_help >&2
      return 1
    fi
    __value="$2"
    if [ -z "$__value" ]; then
      echo "ERROR: empty secret" >&2
      return 1
    fi
    __consumed=2
  fi

  printf -v "$__value_varname" '%s' "$__value"
  printf -v "$__consumed_varname" '%s' "$__consumed"
}

# read_secret <varname>: prompts silently, validates, stores the result in <varname>
read_secret() {
  local __varname="$1"
  local __value=""
  if IFS= read -r -s -p "Enter your secret: " __value; then
    echo >&2 ## just an empty line after read
    if [ -z "$__value" ]; then
      echo "ERROR: empty secret" >&2
      return 1
    fi
  else
    echo -e "\nERROR: aborted" >&2
    return 1
  fi
  printf -v "$__varname" '%s' "$__value"
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
  local secret=""
  local consumed=0
  parse_value_option secret consumed "$@" || return 1
  shift "$consumed"

  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  check_names "$service" "$account" || return 1

  if [ "$consumed" -eq 0 ]; then
    read_secret secret || return 1
  fi
  security add-generic-password -a "$account" -s "$service" -D "$KIND" -w "$secret"
}

secrets__get() {
  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  check_names "$service" "$account" || return 1
  security find-generic-password -a "$account" -s "$service" -D "$KIND" -w
}

secrets__update() {
  local secret=""
  local consumed=0
  parse_value_option secret consumed "$@" || return 1
  shift "$consumed"

  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  check_names "$service" "$account" || return 1

  if [ "$consumed" -eq 0 ]; then
    read_secret secret || return 1
  fi
  security add-generic-password -a "$account" -s "$service" -D "$KIND" -w "$secret" -U
}

secrets__delete() {
  check_number_of_args "$#" 1 2 || return 1
  local service="$1"
  local account="${2:-$DEFAULT_ACCOUNT}"
  check_names "$service" "$account" || return 1
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
