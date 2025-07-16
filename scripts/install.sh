#!/bin/sh

APP_DIR="$HOME/.local/share/shrine-loader"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"

cp -r app "$APP_DIR/"
cp shrine_loader.py "$APP_DIR/"

# Create desktop entry
echo "[Desktop Entry]
Name=Shrine Loader
Comment=Graphical wrapper around thcrap for Linux
Exec=sh -c 'cd "$HOME/.local/share/shrine-loader" && python3 -m shrine_loader'
Icon=shrine_loader
Terminal=false
Type=Application
Categories=Game;
StartupWMClass=shrine-loader" > resources/shrine_loader.desktop

cp resources/shrine_loader.desktop "$DESKTOP_DIR/Shrine Loader.desktop"
cp resources/icon.png "$ICON_DIR/shrine_loader.png"

# Create launcher script
echo "#!/bin/sh
python3 -m shrine_loader" > "$BIN_DIR/shrine-loader"
chmod +x "$BIN_DIR/shrine-loader"

echo "Installed Shrine Loader locally. Make sure $BIN_DIR is in your PATH."