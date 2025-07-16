#!/bin/bash
# Uninstall script for Shrine Loader

APP_DIR="$HOME/.local/share/shrine-loader"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

DONT_CLEANUP_WINE_PREFIX=false
INSTALLATION_PATH="$HOME/.shrine-loader"

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
rm -f "$BIN_DIR/shrine-loader"
rm -f "$DESKTOP_DIR/Shrine Loader.desktop"

echo "Uninstalled Shrine Loader and cleaned up installation files."