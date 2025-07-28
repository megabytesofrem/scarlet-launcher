#!/bin/sh

APP_DIR="$HOME/.local/share/scarlet"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"

cp -r app "$APP_DIR/"
cp -r resources "$APP_DIR/"
cp scarlet.py "$APP_DIR/"

# Create desktop entry
echo "[Desktop Entry]
Name=Scarlet
Comment=Graphical wrapper around thcrap for Linux
Exec=sh -c 'cd "$HOME/.local/share/scarlet" && python3 -m scarlet'
Icon=scarlet
Terminal=false
Type=Application
Categories=Game;
StartupWMClass=scarlet" > "$DESKTOP_DIR/Scarlet.desktop"

cp resources/icon.png "$ICON_DIR/scarlet.png"

# Create launcher script
echo "#!/bin/sh
python3 -m scarlet" > "$BIN_DIR/scarlet"
chmod +x "$BIN_DIR/scarlet"

echo "Installed Scarlet locally. Make sure $BIN_DIR is in your PATH."