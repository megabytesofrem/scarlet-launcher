#!/bin/sh

set -e

build_wine() {
    echo "Building Wine..."
    mkdir -p tmp
    mkdir -p /app/wine
    wget -O tmp/wine-10.12.tar.xz https://dl.winehq.org/wine/source/10.x/wine-10.12.tar.xz
    tar -xf tmp/wine-10.12.tar.xz -C tmp
    cd tmp/wine-10.12 && ./tools/make_makefiles && autoreconf -fiv
    mkdir build && cd build
    ../configure --prefix=/app/wine --enable-win64
    make -j$(nproc)
    make install

    echo "Wine built and installed."
}

build_icoutils() {
    echo "Building icoutils..."
    wget -O /tmp/icoutils.tar.bz2 https://savannah.nongnu.org/download/icoutils/icoutils-0.32.3.tar.bz2

    tar -xf /tmp/icoutils.tar.bz2 -C /tmp
    cd /tmp/icoutils-0.32.3
    ./configure --prefix=/app/wine
    make -j$(nproc)
    make install

    echo "icoutils built and installed."
}

build_wine
build_icoutils

# Clean up temporary files
cd ../../../
rm -rf tmp/wine-10.12
rm -rf tmp/icoutils-0.32.3