#!/usr/bin/env bash
set -euo pipefail

APP_NAME="io.synaptical.ori.simulator"

###############################################################################
# Detect platform
###############################################################################
OS_TYPE="$(uname -s)"

case "$OS_TYPE" in
  Darwin)
    MANIFEST_DIR="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
    ;;
  Linux)
    MANIFEST_DIR="$HOME/.mozilla/native-messaging-hosts"
    ;;
  *)
    echo "❌ Unsupported OS: $OS_TYPE"
    echo "   This script currently supports macOS and Linux only."
    exit 1
    ;;
esac

MANIFEST_PATH="$MANIFEST_DIR/${APP_NAME}.json"

###############################################################################
# Remove manifest if it exists
###############################################################################
if [ -f "$MANIFEST_PATH" ]; then
  echo "🗑  Removing native messaging manifest:"
  echo "    $MANIFEST_PATH"
  rm "$MANIFEST_PATH"
  echo "✅ Uninstall complete."
else
  echo "ℹ️  No manifest found for '$APP_NAME' at:"
  echo "    $MANIFEST_PATH"
  echo "Nothing to uninstall."
fi

# Open Finder to path to verify
if [[ "$OS_TYPE" == "Darwin" ]]; then
  open -R "$MANIFEST_DIR"
fi
