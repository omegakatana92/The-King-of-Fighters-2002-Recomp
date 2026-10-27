# Building

The project is plain C11/C++14 on CMake.  Windows and Linux use separate
build directories; both consume the same `neogeorecomp/` source and the same
`src/game.c` ROM description.

## Prerequisites

**Windows x64**

- Visual Studio 2022 or newer with *Desktop development with C++*
- CMake 3.21+
- SDL2 development package.  The build used SDL2 2.32.10; point
  `SDL2_DIR` at its `cmake` folder.
- Your own unzipped `kof2002` and `neogeo` sets.

**Linux x86_64 / Steam Deck**

- gcc/g++ (C11, C++14), make, CMake 3.21+
- `libsdl2-dev` (Ubuntu 22.04's 2.0.20 was used)
- Your own unzipped sets.

## Prepare the ROMs

The original zip files are never modified.  Either use the helper:

```
powershell -ExecutionPolicy Bypass -File packaging\windows\Prepare-ROMs.ps1
```

or extract the two sets into one directory and run the preparation tool:

```
kof2002_decrypt --rom-path C:\path\to\unzipped --out C:\path\to\roms
```

The tool verifies the input CRCs, performs all four decryptions, extracts the
embedded S ROM, copies the system ROMs, and verifies the known-good output
CRCs.  It fails loudly on a wrong dump.

## Windows

```
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 ^
      -DCMAKE_CONFIGURATION_TYPES=Release ^
      -DKOF2002_ROM_DIR=C:/path/to/roms-src ^
      -DSDL2_DIR=C:/path/to/SDL2/cmake
cmake --build build-windows --config Release --target kof2002
```

The result is `build-windows/Release/KOF 2002.exe`, with `SDL2.dll` copied
next to it.  `build-windows/Release/kof2002_decrypt.exe` is the ROM helper for
packaging.

`KOF2002_ROM_DIR` points at the **original** unzipped set.  During the build,
CMake runs the decrypt tool into `build-windows/roms` and then runs the
recompiler.  The generated C lives in `build-windows/generated/` and is never
committed.

Package a distributable folder:

```
powershell -ExecutionPolicy Bypass -File packaging\windows\package-windows.ps1
```

This writes `dist/windows/KOF 2002-Windows-x64/` and a zip.  It copies no ROM
data.

## Linux

```
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release \
      -DKOF2002_ROM_DIR=/path/to/roms-src
cmake --build build-linux --parallel "$(nproc)"
```

or `./packaging/linux/build-linux.sh /path/to/roms-src`.

The generated C is about 180 MB; on WSL it is much faster to keep
`KOF2002_BUILD_DIR` on the Linux filesystem:

```
KOF2002_BUILD_DIR=$HOME/kof2002-build \
  ./packaging/appimage/build-appimage.sh /path/to/roms-src
```

## AppImage

```
./packaging/appimage/build-appimage.sh /path/to/roms-src
```

The script builds the Release player, assembles an AppDir, bundles the SDL2
it linked against, adds `AppRun`, desktop file, icon and licenses, and invokes
`appimagetool` (downloaded from the AppImage continuous release if needed).
Output:

```
dist/steamdeck/KOF 2002-SteamDeck-x86_64.AppImage
```

The AppImage contains the player and `kof2002_decrypt`, never ROMs.

## Toolkit source

`neogeorecomp/` is the v0.2.0 toolkit source (upstream commit
`af96b2b4b39b42b392b17bcaa6a74a5f27088202`) with the generic runtime
extensions present in the sibling Garou project snapshot, the shared M1
bank-mapping/audio-sync repair, and an optional cycle-count report in
`--verify`.  No KOF 2002-specific addresses or patches were added to the
toolkit.  The upstream tree, submodule sources
(`ext/musashi`, `ext/z80`, `ext/ymfm`) and licenses are included so the
project builds offline.

The original installed toolkit under
`C:\Users\omega\Documents\tools\neogeorecomp-v0.2.0-win-x64\...` was not
modified.
