#!/usr/bin/env bash
###############################################################################
# Synaptical Webclipper - Build
# Builds the Synaptical Webclipper Firefox extension
###############################################################################

# Guard against repeated sourcing
[[ "${BASH_SOURCE[0]}" != "${0}" && -n "${_LOADED_synaptical_webclipper_firefox_build:-}" ]] && return 0

source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
synaptical_webclipper_firefox_build() {
  log_info "Building Synaptical Webclipper Firefox extension..."

  echo "Project root: $PROJECT_ROOT"
  echo "Tasks dir:    $TASKS_DIR"
  echo "Lib dir:      $LIB_DIR"

  # Clean previous build
  log_info "Cleaning previous build..."
  rm -rf "$PROJECT_ROOT/build"
  mkdir -p "$PROJECT_ROOT/build"

  "$PROJECT_ROOT/node_modules/.bin/swc" ./src \
    --out-dir "$PROJECT_ROOT/build" \
    --strip-leading-paths \
    --source-maps

  log_success "Build completed successfully."
}

# Mark loaded (for source guard)
readonly _LOADED_synaptical_webclipper_firefox_build=1

synaptical_webclipper_firefox_build "$@"
