#!/bin/sh

set -e

clean_build_files() {
    echo "Cleaning up remaining build artifacts..."
    rm -rf .flatpak-builder build repo
}

# Check for required commands and install missing dependencies
check_deps() {
    REQUIRED_COMMANDS=("gcc" "make" "wget" "flex" "bison" "tar")
    MISSING_COMMANDS=()

    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            MISSING_COMMANDS+=("$cmd")
        fi
    done

    if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
        echo "The following commands are missing: ${MISSING_COMMANDS[*]}"
        install_deps
    else
        echo "All required commands are present."
    fi
}

install_deps() {
    os=$(grep ^ID= /etc/os-release | cut -d'=' -f2)
    if [ "$os" = "ubuntu" ] || [ "$os" = "debian" ]; then
        sudo apt update
        sudo apt install -y build-essential libx11-dev libxext-dev libxrandr-dev libxrender-dev libxi-dev libfreetype6-dev flex bison
    elif [ "$os" = "fedora" ]; then
        sudo dnf group install -y "C Development Tools and Libraries"
        sudo dnf install -y libX11-devel libXext-devel libXrandr-devel libXrender-devel libXi-devel freetype-devel flex bison
    elif [ "$os" = "arch" ]; then
        sudo pacman -S --noconfirm base-devel libx11 libxext libxrandr libxrender libxi freetype2 flex bison
    else
        echo "Unsupported OS: $os"
        exit 1
    fi
}

bundle_flatpak() {
    # Create the distribution directory which holds the flatpak bundle
    mkdir -p dist

    flatpak-builder \
        --force-clean \
        --repo=dist/repo \
        build-dir \
        com.megabytesofrem.scarlet.yaml

    flatpak build-bundle dist/repo dist/scarlet.flatpak com.megabytesofrem.scarlet
}

# Main script execution starts here
check_deps
clean_build_files && bundle_flatpak

# uninstall the old version if it exists
if flatpak list | grep -q com.megabytesofrem.scarlet; then
    flatpak uninstall -y com.megabytesofrem.scarlet
fi

# install the new version
flatpak install --user --bundle scarlet.flatpak