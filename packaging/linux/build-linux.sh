#!/usr/bin/env bash
# Build the native Linux x86_64 player (no AppImage packaging).
# Prerequisites: gcc, g++, cmake 3.21+, make, libsdl2-dev.
#
# Usage: ./packaging/linux/build-linux.sh [ROM_DIR]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROMS="${1:-$ROOT/roms-src}"
BUILD="${KOF2002_BUILD_DIR:-$ROOT/build-linux}"

cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release "-DKOF2002_ROM_DIR=$ROMS"
cmake --build "$BUILD" --parallel "$(nproc)"
echo "built $BUILD/KOF 2002"
