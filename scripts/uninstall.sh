#!/bin/bash
# Uninstall script for Scarlet

APP_DIR="$HOME/.local/share/scarlet"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

DONT_CLEANUP_WINE_PREFIX=false
INSTALLATION_PATH="$HOME/.scarlet"

if [ "$1" == "--no-wine-prefix" ]; then
    DONT_CLEANUP_WINE_PREFIX=true
fi

if [ "$DONT_CLEANUP_WINE_PREFIX" == "true" ]; then
    echo "Skipping cleanup of Wine prefix."
else
    echo "Cleaning up Wine prefix..."
    
    rm -rf "$INSTALLATION_PATH/.wine-thcrap"
    rm -rf "$INSTALLATION_PATH/bin"
    rm -rf "$INSTALLATION_PATH/repos"
    rm -rf "$INSTALLATION_PATH/thcrap"
    rm -rf "$INSTALLATION_PATH/thcrap.zip"
fi

# Remove application files
rm -rf "$APP_DIR"
rm -f "$BIN_DIR/scarlet"
rm -f "$DESKTOP_DIR/Scarlet.desktop"

echo "Uninstalled Scarlet and cleaned up installation files."