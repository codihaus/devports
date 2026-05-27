#!/bin/bash
set -e

REPO="codihaus/devports"
APP_NAME="DevPorts"
INSTALL_DIR="/Applications"

echo "Installing $APP_NAME..."

LATEST=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST" ]; then
  echo "Error: Could not fetch latest release"
  exit 1
fi

echo "Latest version: $LATEST"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -sL "https://github.com/$REPO/releases/download/$LATEST/$APP_NAME.app.zip" -o "$TMPDIR/$APP_NAME.app.zip"
ditto -x -k "$TMPDIR/$APP_NAME.app.zip" "$TMPDIR"
xattr -cr "$TMPDIR/$APP_NAME.app"

if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
  echo "Removing previous version..."
  rm -rf "$INSTALL_DIR/$APP_NAME.app"
fi

cp -R "$TMPDIR/$APP_NAME.app" "$INSTALL_DIR/"

echo "Installed to $INSTALL_DIR/$APP_NAME.app"
echo ""
echo "To start: open /Applications/$APP_NAME.app"
echo "To launch at login: copy com.devports.app.plist to ~/Library/LaunchAgents/"
