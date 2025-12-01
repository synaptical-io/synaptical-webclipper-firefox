#!/usr/bin/env bash
###############################################################################
# Task Bootstrapper - Initializes environment for task scripts
#
# SOURCE THIS FILE FIRST in any script. It provides:
#   PROJECT_ROOT  - Absolute path to project root (contains .vscode/)
#   LIB_DIR       - $PROJECT_ROOT/setup/lib
#   TASKS_DIR     - $PROJECT_ROOT/tasks
#   CALLER_DIR    - Directory of the script that sourced this
#   CALLER_FILE   - Full path to the script that sourced this
#
# Also loads: logging.sh (log_info, log_warn, log_error, log_success, log_header)
#
# Usage from tasks/:     source "${BASH_SOURCE[0]%/*}/lib/bootstrap.sh"
###############################################################################

# Include guard
[[ -n "${_LOADED_BOOTSTRAP:-}" ]] && return 0

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Find project root by walking up until we find .vscode/tasks.json
# This is the single definition of "what is a project root"
# -----------------------------------------------------------------------------
_find_project_root() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/.vscode/tasks.json" ]] && {
      echo "$dir"
      return 0
    }
    dir="${dir%/*}"
    [[ -z "$dir" ]] && dir="/"
  done
  return 1
}

# -----------------------------------------------------------------------------
# Resolve symlinks to find true location of a file
# -----------------------------------------------------------------------------
_resolve_symlinks() {
  local source="$1"
  while [[ -L "$source" ]]; do
    local target
    target="$(readlink "$source")"
    if [[ "$target" == /* ]]; then
      source="$target"
    else
      source="$(dirname "$source")/$target"
    fi
  done
  echo "$source"
}

# -----------------------------------------------------------------------------
# Main bootstrap logic
# -----------------------------------------------------------------------------

# BASH_SOURCE[1] is the script that sourced us
# BASH_SOURCE[0] is this file (bootstrap.sh)
if [[ ${#BASH_SOURCE[@]} -lt 2 ]]; then
  echo "[FATAL] bootstrap.sh must be sourced, not executed directly" >&2
  exit 1
fi

# Resolve the calling script through any symlinks
_caller_resolved="$(_resolve_symlinks "${BASH_SOURCE[1]}")"
CALLER_FILE="$(cd -- "$(dirname -- "$_caller_resolved")" && pwd -P)/$(basename -- "$_caller_resolved")"
CALLER_DIR="$(dirname "$CALLER_FILE")"
unset _caller_resolved

# Find project root
PROJECT_ROOT="$(_find_project_root "$CALLER_DIR")" || {
  echo "[FATAL] Cannot find project root from $CALLER_DIR" >&2
  echo "        (Looking for setup/setup.sh marker file)" >&2
  exit 1
}

# Derive standard paths
TASKS_DIR="$PROJECT_ROOT/tasks"
LIB_DIR="$TASKS_DIR/lib"

# Export as readonly
readonly PROJECT_ROOT CALLER_DIR CALLER_FILE
# shellcheck disable=SC2034
readonly LIB_DIR TASKS_DIR

# Load logging library
if [[ -f "$LIB_DIR/logging.sh" ]]; then
  # shellcheck source=./logging.sh
  source "$LIB_DIR/logging.sh"
else
  echo "[FATAL] Cannot find logging library at $LIB_DIR/logging.sh" >&2
  exit 1
fi

# Mark as loaded
readonly _LOADED_BOOTSTRAP=1
