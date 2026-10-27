# Third-party notices

This project is a game-specific host for **neogeorecomp**, a static
recompilation toolkit for SNK Neo Geo.  It contains original project code and
unmodified or adapted third-party code.  Each part keeps its own license; the
PolyForm Noncommercial license in `LICENSE` applies only to the original
project code (see `LICENSE-STATUS.md`).

No SNK/Playmore ROM data, Neo Geo BIOS, or recompiled output generated from
them is distributed with this repository or its binary releases.  The user
supplies their own legally obtained dumps.

## neogeorecomp (MIT)

`neogeorecomp/` is the upstream toolkit, Copyright (c) 2026 sp00nznet, MIT
License.  The full text is in `neogeorecomp/LICENSE`; upstream attribution is
in `neogeorecomp/NOTICE`.

This project uses the v0.2.0 runtime/recompiler source (upstream commit
`af96b2b4b39b42b392b17bcaa6a74a5f27088202`) plus the generic runtime
extensions already present in the sibling Garou project snapshot: the MVS
watchdog, fullscreen output, the fixed-layer bank selectors, the program bank
map and the NEO-SMA random latch.  No game-specific title hacks were added to
the toolkit for KOF 2002.  The code that loads and recompiles the game is the
same code path used by the other supported titles.

Generic fixes made while bringing up this title, documented in
`docs/CHANGELOG.md`, are also present:

- correct MULU/MULS and DBcc dynamic-cycle accounting in the emitter;
- an optional cycle-count report in `--verify`;
- an SDL software-renderer fallback and checked window/texture creation;
- the shared M1 bank-mapping repair and pull-based `audio_sync()` from the
  Garou audio repair, which keep Z80 music/SFX data correctly mapped.

These are timing/robustness changes, not KOF 2002-specific patches.

## Musashi (MIT)

`neogeorecomp/ext/musashi/` - Motorola 68000 interpreter, Copyright (c)
1998-2001 Karl Stenerud, MIT License.  Used as the fallback interpreter, the
`--verify` oracle, the source of 68000 cycle counts, and the conformance
corpus.  Full text: `neogeorecomp/LICENSES/Musashi.txt`.

## z80 (MIT)

`neogeorecomp/ext/z80/` - Zilog Z80 core, Copyright (c) 2019 Nicolas
Allemand, MIT License.  Used as the sound CPU.  Full text:
`neogeorecomp/LICENSES/z80.txt`.

## ymfm (BSD-3-Clause)

`neogeorecomp/ext/ymfm/` - Yamaha FM synthesis, Copyright (c) 2021 Aaron
Giles, BSD 3-Clause License.  Synthesizes the YM2610's FM, SSG and ADPCM-A/B.
Full text: `neogeorecomp/LICENSES/ymfm.txt`.

## SDL2 (zlib)

The Windows and Linux builds use SDL2 for the window, audio output and
game-controller input.  Copyright (C) 1997-2025 Sam Lantinga and
contributors.  zlib license; the full text is in
`packaging/windows/SDL2.txt` and is copied into the binary distributions.

## MAME Neo Geo driver references (BSD-3-Clause)

The build-time ROM preparation in `tools/decrypt.c` and the constant tables in
`tools/tables.h` implement the NEO-PCM2 and NEO-CMC 7050/CMC50 protection
algorithms documented and implemented in MAME's Neo Geo driver:

- `src/devices/bus/neogeo/prot_pcm2.cpp`
- `src/devices/bus/neogeo/prot_cmc.cpp`
- `src/devices/bus/neogeo/prot_kof2k2.cpp`
- `src/devices/bus/neogeo/kof2k2.cpp`

Those files are BSD 3-Clause, Copyright (c) S. Smith, David Haywood and Fabio
Priuli, with the Neo Geo driver originally by Bryan McPhail, Ernesto Corvi,
Andrew Prime and Zsolt Vasvari.  The BSD 3-Clause terms are reproduced below.
The port is limited to the data-decryption algorithms and tables; it is not a
copy of the MAME emulator.

```
BSD 3-Clause License

Copyright (c) MAME contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## Game data

*The King of Fighters 2002* is Copyright SNK / Playmore.  The Neo Geo system
ROMs are Copyright SNK.  This project does not grant any right to those works.
ROMs and BIOS files are not included; `packaging/windows/Prepare-ROMs.ps1` and
the AppRun launcher only process files the user already has.
