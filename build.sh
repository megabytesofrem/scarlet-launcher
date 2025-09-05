#!/bin/bash
# Scarlet Launcher Build Script

set -e  # Exit on any error

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"

# Default to Release build, but allow Debug via environment variable
BUILD_TYPE="${BUILD_TYPE:-Release}"

echo "=== Scarlet Launcher Build Script ==="
echo "Project directory: ${PROJECT_DIR}"
echo "Build directory: ${BUILD_DIR}"
echo "Build type: ${BUILD_TYPE}"

# Create build directory if it doesn't exist
if [ ! -d "${BUILD_DIR}" ]; then
    echo "Creating build directory..."
    mkdir -p "${BUILD_DIR}"
fi

# Change to build directory
cd "${BUILD_DIR}"

# Configure with CMake
echo "Configuring project with CMake..."
cmake "${PROJECT_DIR}" -DCMAKE_BUILD_TYPE="${BUILD_TYPE}"

# Build the project
echo "Building project..."
cmake --build . --parallel $(nproc)

echo "Build completed successfully!"
echo "Executable location: ${BUILD_DIR}/scarlet"
echo ""
echo "To run the application:"
echo "  cd ${BUILD_DIR}"
echo "  ./scarlet"
