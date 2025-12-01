#!/usr/bin/env bash
###############################################################################
# logging.sh - Standardized logging with colors and timestamps
#
# Provides: log_info, log_success, log_warn, log_error, log_header
#
# Respects NO_COLOR environment variable.
# Warns/errors go to stderr.
###############################################################################

[[ -n "${_LOADED_LOGGING:-}" ]] && return 0

# Colors (disabled if NO_COLOR is set or stdout isn't a terminal)
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  readonly _C_RESET='\033[0m'
  readonly _C_RED='\033[0;31m'
  readonly _C_GREEN='\033[0;32m'
  readonly _C_YELLOW='\033[1;33m'
  readonly _C_BLUE='\033[0;34m'
  readonly _C_CYAN='\033[0;36m'
else
  readonly _C_RESET='' _C_RED='' _C_GREEN='' _C_YELLOW='' _C_BLUE='' _C_CYAN=''
fi

_timestamp() { date +'%Y-%m-%d %H:%M:%S'; }

log_info() { echo -e "${_C_BLUE}[$(_timestamp)] [INFO]${_C_RESET}  $*"; }
log_success() { echo -e "${_C_GREEN}[$(_timestamp)] [OK]${_C_RESET}    $*"; }
log_warn() { echo -e "${_C_YELLOW}[$(_timestamp)] [WARN]${_C_RESET}  $*" >&2; }
log_error() { echo -e "${_C_RED}[$(_timestamp)] [ERROR]${_C_RESET} $*" >&2; }

# Header: creates a banner line (default left-aligned, -c for centered)
log_header() {
  local text="$*" max=80 style="left"
  [[ "$1" == "-c" ]] && {
    shift
    text="$*"
    style="center"
  }

  # Truncate if needed
  ((${#text} > max - 4)) && text="${text:0:$((max - 5))}…"

  local fill=$((max - ${#text} - 4))
  local banner

  if [[ "$style" == "center" ]]; then
    local left=$((fill / 2))
    local right=$((fill - left))
    printf -v banner '%*s %s %*s' "$left" '' "$text" "$right" ''
    banner="${banner// /=}"
  else
    printf -v banner '%*s' "$fill" ''
    banner="== $text ${banner// /=}"
  fi

  echo -e "\n${_C_CYAN}${banner}${_C_RESET}"
}

readonly _LOADED_LOGGING=1
