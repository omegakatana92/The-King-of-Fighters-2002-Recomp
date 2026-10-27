#!/usr/bin/env bash
# Build the Linux x86_64 player and package it as a Steam Deck AppImage.
#
# Prerequisites: gcc, g++, cmake 3.21+, make, libsdl2-dev, wget (and FUSE,
# or appimagetool's --appimage-extract-and-run path used below).
# The user's ROMs are never bundled: the AppImage contains the recompiled
# player and the build-time preparation tool only.
#
# Usage:
#   ./packaging/appimage/build-appimage.sh [ROM_DIR]
# Default ROM_DIR=$ROOT/roms-src, output dist/steamdeck/...
#
# Override the build directory (useful when the source tree is on a slow
# shared filesystem and you want the 180 MB of generated C on ext4):
#   KOF2002_BUILD_DIR=$HOME/kof2002-build ./packaging/appimage/build-appimage.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROMS="${1:-$ROOT/roms-src}"
BUILD="${KOF2002_BUILD_DIR:-$ROOT/build-linux}"
APPDIR="$BUILD/AppDir"
OUT="$ROOT/dist/steamdeck/KOF 2002-SteamDeck-x86_64.AppImage"

echo "== configure/build (Release) =="
cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release "-DKOF2002_ROM_DIR=$ROMS"
cmake --build "$BUILD" --parallel "$(nproc)"

echo "== assemble AppDir =="
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
         "$APPDIR/usr/share/doc/kof2002"
cp "$BUILD/KOF 2002" "$APPDIR/usr/bin/KOF2002"
cp "$BUILD/kof2002_decrypt" "$APPDIR/usr/bin/kof2002_decrypt"
strip --strip-unneeded "$APPDIR/usr/bin/KOF2002" 2>/dev/null || true
strip --strip-unneeded "$APPDIR/usr/bin/kof2002_decrypt" 2>/dev/null || true

# Bundle the SDL2 the build linked against; SteamOS's system copy may differ.
SDL=$(ldd "$BUILD/KOF 2002" | awk '/libSDL2-2\.0\.so\.0/{print $3; exit}')
if [ -n "$SDL" ]; then cp "$SDL" "$APPDIR/usr/lib/"; fi

cp "$ROOT/packaging/appimage/kof2002.png" "$APPDIR/kof2002.png"
cp "$ROOT/packaging/appimage/kof2002.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/kof2002.png"
cp "$ROOT/packaging/appimage/kof2002.desktop" "$APPDIR/kof2002.desktop"
cp "$ROOT/packaging/appimage/kof2002.desktop" "$APPDIR/usr/share/applications/kof2002.desktop"
cp "$ROOT/packaging/appimage/README.txt" "$APPDIR/usr/share/doc/kof2002/README.txt"
cp "$ROOT/LICENSE" "$APPDIR/usr/share/doc/kof2002/LICENSE.txt"
cp "$ROOT/LICENSE-STATUS.md" "$APPDIR/usr/share/doc/kof2002/LICENSE-STATUS.txt"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$APPDIR/usr/share/doc/kof2002/THIRD_PARTY_NOTICES.txt"
mkdir -p "$APPDIR/usr/share/doc/kof2002/LICENSES"
cp "$ROOT/neogeorecomp/LICENSE" "$APPDIR/usr/share/doc/kof2002/LICENSES/neogeorecomp.txt"
cp "$ROOT/neogeorecomp/NOTICE" "$APPDIR/usr/share/doc/kof2002/LICENSES/neogeorecomp-NOTICE.txt"
cp "$ROOT/neogeorecomp/LICENSES/"*.txt "$APPDIR/usr/share/doc/kof2002/LICENSES/"
cp "$ROOT/packaging/windows/SDL2.txt" "$APPDIR/usr/share/doc/kof2002/LICENSES/SDL2.txt"

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# Steam Input / Gaming Mode may deliver a virtual controller while the
# overlay has focus; let SDL keep reading it.
export SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1
export SDL_GAMECONTROLLER_USE_BUTTON_LABELS=0

# An explicit --rom-path always wins.
has_rom=0
for a in "$@"; do
    [ "$a" = "--rom-path" ] && has_rom=1
done

if [ "$has_rom" = 0 ]; then
    cand=""
    if [ -n "${KOF2002_ROM_DIR:-}" ]; then
        cand="$KOF2002_ROM_DIR"
    elif [ -n "${APPIMAGE:-}" ]; then
        for d in "$(dirname "$APPIMAGE")/roms" \
                 "$(dirname "$APPIMAGE")/roms/kof2002" \
                 "$HOME/Emulation/roms/kof2002" \
                 "$HOME/roms/kof2002" "$HOME/roms"; do
            if [ -d "$d" ]; then cand="$d"; break; fi
        done
    fi
    if [ -n "$cand" ]; then
        if [ -f "$cand/265-s1.s1" ]; then
            # Already prepared (the embedded S ROM is the marker).
            set -- --rom-path "$cand" "$@"
        elif [ -f "$cand/265-p2.sp2" ] && [ -f "$cand/265-m1.m1" ]; then
            # The user pointed us at the original encrypted set: prepare a
            # per-user copy once, then launch from it.
            CACHE="$HOME/.local/share/kof2002/roms"
            if [ ! -f "$CACHE/265-s1.s1" ]; then
                mkdir -p "$CACHE"
                "$HERE/usr/bin/kof2002_decrypt" --rom-path "$cand" --out "$CACHE" || exit 1
            fi
            set -- --rom-path "$CACHE" "$@"
        else
            set -- --rom-path "$cand" "$@"
        fi
    fi
fi

# Steam Deck / Gaming Mode wants a fullscreen game.  Keep --headless and an
# explicit --scale/--fullscreen from being overridden.
add_fs=1
for a in "$@"; do
    case "$a" in --headless|--fullscreen|--scale) add_fs=0;; esac
done
[ "$add_fs" = 1 ] && set -- --fullscreen "$@"

exec "$HERE/usr/bin/KOF2002" "$@"
EOF
chmod +x "$APPDIR/AppRun"

echo "== appimagetool =="
mkdir -p "$ROOT/dist/steamdeck"
cp "$ROOT/packaging/appimage/README.txt" "$ROOT/dist/steamdeck/README.txt"
mkdir -p "$ROOT/dist/steamdeck/LICENSES"
cp "$ROOT/LICENSE" "$ROOT/dist/steamdeck/LICENSES/LICENSE.txt"
cp "$ROOT/LICENSE-STATUS.md" "$ROOT/dist/steamdeck/LICENSES/LICENSE-STATUS.txt"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$ROOT/dist/steamdeck/LICENSES/THIRD_PARTY_NOTICES.txt"
cp "$ROOT/neogeorecomp/LICENSE" "$ROOT/dist/steamdeck/LICENSES/neogeorecomp.txt"
cp "$ROOT/neogeorecomp/NOTICE" "$ROOT/dist/steamdeck/LICENSES/neogeorecomp-NOTICE.txt"
cp "$ROOT/neogeorecomp/LICENSES/"*.txt "$ROOT/dist/steamdeck/LICENSES/"
cp "$ROOT/packaging/windows/SDL2.txt" "$ROOT/dist/steamdeck/LICENSES/SDL2.txt"
TOOL="${APPIMAGETOOL:-$HOME/appimagetool-x86_64.AppImage}"
if [ ! -x "$TOOL" ]; then
    TOOL="$BUILD/appimagetool.AppImage"
    wget -q -O "$TOOL" \
      https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$TOOL"
fi
ARCH=x86_64 "$TOOL" --appimage-extract-and-run --no-appstream "$APPDIR" "$OUT"
chmod +x "$OUT"
echo "wrote $OUT"
