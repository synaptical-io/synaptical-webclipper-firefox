#!/usr/bin/env bash
###############################################################################
# Synaptical Webclipper - Distribution Build Script
# Copies latest build files to the 'dist' directory for packaging.
###############################################################################

# Guard against repeated sourcing
[[ "${BASH_SOURCE[0]}" != "${0}" && -n "${_LOADED_synaptical_webclipper_firefox_dist:-}" ]] && return 0

source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
synaptical_webclipper_firefox_dist() {
  log_info "Building Synaptical Webclipper Firefox extension..."

  local build_dir="$PROJECT_ROOT/build"
  local dist_dir="$PROJECT_ROOT/dist"

  # 1. If build dir is missing or has no files, rebuild
  if ! find "$build_dir" -type f -print -quit 2>/dev/null | grep -q .; then
      echo "Build directory is empty or missing. Running build..."
      "$TASKS_DIR"/tasks/build.sh    # ⬅️ replace with your actual build command if needed
  fi

  # 2. Ensure dist exists
  mkdir -p "$dist_dir"

  # 3. Sync build → dist, deleting anything in dist that isn't in build
  rsync -av --delete "$build_dir"/ "$dist_dir"/

  log_success "Build completed successfully."
}

# Mark loaded (for source guard)
readonly _LOADED_synaptical_webclipper_firefox_dist=1

synaptical_webclipper_firefox_dist "$@"
