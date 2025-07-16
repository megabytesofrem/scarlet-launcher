#!/bin/bash

## thcrap-linux.sh
## Linux script for the Touhou Community Reliant Automatic Patcher (thcrap)
## Partially made with the help of ChatGPT

# TODO: Make a GUI for steam deck users

# === Configurable paths ===
WINEPREFIX="$HOME/.wine-thcrap"
THCRAP_LINK="https://github.com/thpatch/thcrap/releases/download/2025-07-06/thcrap.zip"
THCRAP_DIR="$HOME/Documents/Games/thcrap"
THCRAP_LAUNCHER="$THCRAP_DIR/thcrap.exe"
THCRAP_LOADER="$THCRAP_DIR/thcrap_loader.exe"

export WINEPREFIX
export WINEDEBUG=-all

download_thcrap() {
    mkdir -p "$THCRAP_DIR"
    
    echo "Downloading thcrap (The Touhou Community Reliant Automatic Patcher)..."
    if command -v wget &> /dev/null; then
        wget -q --show-progress "$THCRAP_LINK" -O thcrap.zip
    elif command -v curl &> /dev/null; then
        curl -L "$THCRAP_LINK" -o thcrap.zip
    else
        echo "Neither wget nor curl is installed. Please install one of them to download thcrap."
        exit 1
    fi

    # Unzip the downloaded file
    echo "Unzipping thcrap..."
    unzip -q thcrap.zip -d "$THCRAP_DIR"

    [ $? -ne 0 ] && { echo "Failed to unzip thcrap for some reason."; exit 1; }
}

create_prefix() {
    echo "Creating prefix.. " && WINEPREFIX="$HOME/.wine-thcrap" wineboot
    winetricks --force \
    dsound \
    d3dx9_36 \
    dxdiag \
    xact \
    dinput8 \
    vcrun2010 \
    corefonts
}

[ -d "$THCRAP_DIR" ] || download_thcrap
[ -d "$WINEPREFIX" ] || create_prefix

# List of all patched executables in the thcrap directory
executables=("$THCRAP_DIR"/*\(en\).exe)

# If there are no executables, launch the loader
if [ ${#executables[@]} -eq 0 ]; then
    echo "No executables found in $THCRAP_DIR. Launching loader..."
    [ -f "$THCRAP_LOADER" ] && wine "$THCRAP_LOADER" || { echo "thcrap_loader.exe not found!"; exit 1; }
fi

echo "Select an executable to run:"
echo "0) Launch thcrap again to reconfigure"

for i in "${!executables[@]}"; do
    echo "$((i+1))) $(basename "${executables[$i]}")"
done

read -rp "Select an option: " choice
if [ "$choice" -eq 0 ]; then
    echo "Reconfiguring thcrap..."
    wine "$THCRAP_LOADER"
else
    if [ "$choice" -ge 1 ] && [ "$choice" -le "${#executables[@]}" ]; then
        selected_executable="${executables[$((choice-1))]}"
        echo "Launching $selected_executable..."
        wine "$selected_executable"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
fi