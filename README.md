# The King of Fighters 2002 — native static recompilation

A native recompilation of **The King of Fighters 2002** (SNK/Playmore, NGH-265,
MVS/AES) built on [neogeorecomp](https://github.com/sp00nznet/neogeorecomp).
The game's Motorola 68000 program is translated ahead of time into C and runs
natively against a model of the MVS board.  The Z80 sound driver and YM2610
are modelled.  Musashi remains the fallback interpreter and the `--verify`
oracle.

This repository contains no game data.  You supply your own legally obtained
`kof2002.zip` and `neogeo.zip`; the build prepares them locally.

## Deliverables

| Platform | Artifact |
|---|---|
| Windows x64 | GitHub Releases: `KOF 2002-Windows-x64.zip` |
| Steam Deck / Linux x86_64 | GitHub Releases: `KOF 2002-SteamDeck-x86_64.AppImage` |
| Source | this repository; `KOF 2002-Source.zip` is also a release asset |

Both binaries are native builds.  The AppImage is not a renamed Windows
executable and does not wrap a conventional emulator.  Release assets include
a `SHA256SUMS.txt`; no ROMs, BIOS files or build trees are published.

## Status

| Area | Result |
|---|---|
| ROM dump | Validated against MAME SHA1/CRC32 (see `docs/ROM-VALIDATION.md`) |
| Program | 1 MB fixed + 4 MB banked; NEO-PCM2 block order restored |
| Graphics | NEO-CMC 7050 C-ROM decryption; 128 KB S ROM extracted from C data |
| Audio | CMC50 M1 + NEO-PCM2 V-ROM decryption; M1 bank-mask repair; continuous BGM/SFX through select and match in native, interpreter and AppImage; subjective mix not auditioned |
| Boot | Verified: BIOS -> Playmore logo -> title -> attract -> coin/start -> character select -> order select -> match |
| Native recompilation | 100.00% of the 3,000-frame boot and 9,000-frame menu+match; 99.95% of the 19,000-frame scripted session (50,932 dispatch entries) |
| `--verify` | 0 register/flag/bus mismatches and 0 cycle-count differences on every run after the timing fixes |
| Windows window | Verified: native SDL2 window, 400 frames, 100.00% native, screenshot written |
| Linux AppImage | Built and launched headless and fullscreen under Xvfb at 1280x800; bundled SDL2 resolved; frame byte-identical to Windows native. Physical Deck untested |
| Toolkit regressions | `ng_conformance` 59/60 (reference 59/60); `ng_gamepad_test` all checks pass |
| Physical Steam Deck | **Not tested** (no hardware available) |

## What works

- Real MVS BIOS boot (`sp-s2.sp1`): memory test, eye-catcher, coin/start.
- Program banking, sprite renderer (L0 shrink, sticky chains), fixed layer,
  both palette banks and the raster timer.
- Z80 sound driver with NMI/reply latches, ROM banking and YM2610 FM/SSG/
  ADPCM-A/B.
- Keyboard and SDL2 GameController input, two players, hot-plug.
- Generic MVS watchdog, backup RAM and uPD4990A calendar.

## Getting the ROMs ready

You need:

- `kof2002.zip` - the MAME parent set (p1, p2, c1-c8, m1, v1, v2).
- `neogeo.zip` - the system set.  The tested BIOS is `sp-s2.sp1`; the runtime
  also uses `sfix.sfix`, `sm1.sm1` and `000-lo.lo`.

On Windows, run `packaging/windows/Prepare-ROMs.ps1`; on Linux, unzip both
sets into one flat directory (a merged set's `kof2002/` parent files must be
copied next to the BIOS files) and run:

```
kof2002_decrypt --rom-path /path/to/unzipped --out /path/to/roms
```

The original archives are never modified.  The tool checks the input CRCs,
performs the four decryptions, extracts the embedded S ROM, and verifies the
known-good output CRCs.  See `docs/ROM-VALIDATION.md`.

## Running

```
KOF 2002.exe --rom-path C:\path\to\roms
./KOF\ 2002-SteamDeck-x86_64.AppImage --rom-path /path/to/roms
```

Keyboard: arrows; **Z X C V** = A B C D; **5** = coin; **1/2** = start;
**3** = select; **9** = service; **F2** = test; **F11** = fullscreen;
**Esc** = quit.

Gamepad: D-pad/left stick; **A B X Y** = A B C D; **Start**; **Back/View** =
coin; **left shoulder** = select.  The AppImage starts fullscreen and
pillarboxes to 4:3; it never stretches to 16:10.

Options: `--rom-path`, `--bios`, `--bios-path`, `--headless`, `--frames N`,
`--screenshot N:FILE`, `--input FILE`, `--interp`, `--verify`,
`--dump-misses FILE`, `--scale N`, `--fullscreen`, `--mute`, `--wav FILE`.

## Building

See `docs/BUILDING.md` for prerequisites and exact commands.  In short:

```
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 ^
      -DCMAKE_CONFIGURATION_TYPES=Release ^
      -DKOF2002_ROM_DIR=C:/path/to/roms-src ^
      -DSDL2_DIR=C:/path/to/SDL2/cmake
cmake --build build-windows --config Release --target kof2002
```

```
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release \
      -DKOF2002_ROM_DIR=/path/to/roms-src
cmake --build build-linux --parallel "$(nproc)"
```

The build generates about 180 MB of C in `build-*/generated/`; that output is
derived from the ROM and is never committed.

## Measured coverage

These are measured `--verify` runs, not a claim about every code path:

| Session | Blocks checked | Mismatches | Native | Interpreted | Uncovered |
|---|---:|---:|---:|---:|---:|
| 2,000-frame boot | 1,087,599 | 0 | 100.00% | 38 | 0 |
| 9,000-frame menu + match | 6,413,253 | 0 | 100.00% | 76 | 0 |
| 19,000-frame scripted play | 12,499,080 | 0 | 99.95% | 179,165 | 141 |

No cycle-count differences remained after the MULU/MULS and DBcc timing
fixes.  The interpreted instructions are a routine copied to work RAM and
runtime-only entry points from paths the profile pass did not seed; they run
correctly in Musashi.

Audio was validated separately over the full 9,000-frame coin/start/select/
match path.  The pre-fix capture had 55 silent one-second windows and a 10 s
stop at 102 s.  After the M1 bank-mask repair, native, interpreter and the
Linux AppImage all have only the 8 s power-on silence; the minimum RMS after
10 s is 1,040.5.  See `docs/TESTING.md` and `tests/check_audio.py`.

The recompiler's first static pass found 50,122 dispatch entries.  A profile
pass over attract mode plus a scripted play session added 778 runtime-only
entry points (50,932 total), 30,053 routines and 1,179,238 emitted instructions.

## Known limitations

- The full game was not exhaustively played.  The verified path is boot,
  coin/start, character select, order select, a match and a scripted play
  session; other characters, stages, endings, continue and two-player paths
  remain untested.
- Physical Steam Deck hardware and physical controllers were not available.
- Nine of ten sampled native/interpreter boot frames are byte-identical.  At
  frame 1200, four pixels differ at a raster boundary; `--verify` still
  reports 0 CPU/flag/bus mismatches and 0 cycle differences.  The block
  scheduler yields at loop back-edges, while the interpreter stops exactly
  at the event.
- Audio continuity is measured across the full coin/start/select/match path,
  and the attack session contains additional high-frequency transients, but
  the mix was not auditioned by a human in this environment.
- A small number of instructions run in Musashi from work RAM (the game copies
  a routine there); they are not ROM entry points and cannot be recompiled.
  See the final coverage line.
- The build needs SSE2 on Windows x64, as Windows 10/11 itself does.

## Licensing

The original project code is licensed under **PolyForm Noncommercial 1.0.0**.
See `LICENSE` and `LICENSE-STATUS.md`.
`neogeorecomp` is MIT; Musashi and z80 are MIT; ymfm and the MAME Neo Geo
driver references are BSD-3-Clause; SDL2 is zlib.  Full notices are in
`THIRD_PARTY_NOTICES.md` and the per-component files under `neogeorecomp/`.

The game and BIOS are SNK/Playmore property.  No ROM data or recompiled
output is distributed.  PolyForm Noncommercial does not permit commercial
redistribution of this project's code; it does not grant any rights to the
game data.

## Credits

- [neogeorecomp](https://github.com/sp00nznet/neogeorecomp) by sp00nznet.
- [Musashi](https://github.com/kstenerud/Musashi) by Karl Stenerud.
- [superzazu/z80](https://github.com/superzazu/z80) by Nicolas Allemand.
- [ymfm](https://github.com/aaronsgiles/ymfm) by Aaron Giles.
- SDL2 by Sam Lantinga and contributors.
- MAME's Neo Geo driver for the NEO-PCM2 / NEO-CMC 7050 / CMC50 reference
  algorithms and tables.
- The NeoGeo Development Wiki and MAME's `neogeo.cpp` for hardware notes.
