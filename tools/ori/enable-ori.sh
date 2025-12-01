#!/usr/bin/env bash
set -euo pipefail

# Default to real Ori host; use --simulator to target the simulator manifest.
APP_NAME="io.synaptical.ori"

if [[ "${1:-}" == "--simulator" ]]; then
  APP_NAME="io.synaptical.ori.simulator"
  shift
fi

DESCRIPTION="Synaptical Ori"
EXTENSION_ID="synaptical_webclipper@synaptical.io"

# Optional: allow passing the path to the host script as the first non-flag argument.
# Usage:
#   enable-ori.sh [--simulator] [path/to/host-script.py]
#
# If not provided, defaults to tools/ori/ori-simulator.py relative
# to the current working directory.
HOST_SCRIPT_RELATIVE="${1:-tools/ori/ori-simulator.py}"

###############################################################################
# Helper: resolve absolute path to the host script
###############################################################################
if [ ! -f "$HOST_SCRIPT_RELATIVE" ]; then
  echo "❌ Could not find native host script at: $HOST_SCRIPT_RELATIVE"
  echo "   Pass the path as an argument, e.g.:"
  echo "     $0 [--simulator] path/to/ori-simulator.py"
  exit 1
fi

HOST_SCRIPT_ABS="$(
  cd "$(dirname "$HOST_SCRIPT_RELATIVE")"
  pwd
)/$(basename "$HOST_SCRIPT_RELATIVE")"

###############################################################################
# Detect platform and Firefox / Firefox Developer Edition
###############################################################################
OS_TYPE="$(uname -s)"

BROWSER_CHOICE=""

if [[ "$OS_TYPE" == "Darwin" ]]; then
  # macOS: check for .app bundles
  if [ -d "/Applications/Firefox Developer Edition.app" ] || [ -d "$HOME/Applications/Firefox Developer Edition.app" ]; then
    BROWSER_CHOICE="Firefox Developer Edition"
  elif [ -d "/Applications/Firefox.app" ] || [ -d "$HOME/Applications/Firefox.app" ]; then
    BROWSER_CHOICE="Firefox"
  fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
  # Linux: check binaries in PATH (prefer dev edition)
  if command -v firefox-developer-edition >/dev/null 2>&1; then
    BROWSER_CHOICE="Firefox Developer Edition"
  elif command -v firefox >/dev/null 2>&1; then
    BROWSER_CHOICE="Firefox"
  fi
else
  echo "❌ Unsupported OS: $OS_TYPE"
  echo "   This script currently supports macOS and Linux only."
  exit 1
fi

if [[ -z "$BROWSER_CHOICE" ]]; then
  echo "❌ Neither Firefox nor Firefox Developer Edition appears to be installed."
  echo
  echo "Please install one of the following and rerun this script:"
  echo "  - Firefox (stable)"
  echo "  - Firefox Developer Edition"
  exit 1
fi

echo "✅ Detected: $BROWSER_CHOICE"

###############################################################################
# Determine manifest directory based on OS
###############################################################################
if [[ "$OS_TYPE" == "Darwin" ]]; then
  # Per-user native messaging hosts directory for Firefox on macOS
  MANIFEST_DIR="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
elif [[ "$OS_TYPE" == "Linux" ]]; then
  # Per-user native messaging hosts directory for Firefox on Linux
  MANIFEST_DIR="$HOME/.mozilla/native-messaging-hosts"
fi

mkdir -p "$MANIFEST_DIR"

MANIFEST_PATH="$MANIFEST_DIR/${APP_NAME}.json"

###############################################################################
# Ensure host script is executable
###############################################################################
if [ ! -x "$HOST_SCRIPT_ABS" ]; then
  echo "ℹ️  Making host script executable: $HOST_SCRIPT_ABS"
  chmod +x "$HOST_SCRIPT_ABS"
fi

###############################################################################
# Write manifest JSON
###############################################################################
cat > "$MANIFEST_PATH" <<EOF
{
  "name": "${APP_NAME}",
  "description": "${DESCRIPTION}",
  "path": "${HOST_SCRIPT_ABS}",
  "type": "stdio",
  "allowed_extensions": ["${EXTENSION_ID}"]
}
EOF

echo "✅ Native messaging manifest written to:"
echo "   $MANIFEST_PATH"
echo
echo "Manifest 'path' points to:"
echo "   $HOST_SCRIPT_ABS"

# Open Finder to path to verify
if [[ "$OS_TYPE" == "Darwin" ]]; then
  open -R "$MANIFEST_DIR"
fi
