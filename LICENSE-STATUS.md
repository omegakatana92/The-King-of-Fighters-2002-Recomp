# License status

**Status: configured — PolyForm Noncommercial 1.0.0.**

The repository owner confirmed the license as **PolyForm Noncommercial 1.0.0**
(the request's "polymaster" is treated as PolyForm Noncommercial 1.0.0,
consistent with the other NeoGeoRecomp game repositories).  The full text is
in `LICENSE`, with the required notice naming the project contributors.

## What the PolyForm license covers

Only code in this repository that the project authors wrote and have the right
to license, principally:

- `src/` (the KOF 2002 ROM layout and the player entry point)
- `tools/decrypt.c` (the KOF 2002-specific build-time preparation tool)
- `tests/check_audio.py` and the input scripts
- `CMakeLists.txt`, `packaging/`, documentation and scripts written for this
  project

## What it does not cover

- `neogeorecomp/` — the upstream toolkit, **MIT**.  See
  `neogeorecomp/LICENSE` and `neogeorecomp/NOTICE`.
- Musashi, z80 and ymfm — MIT / MIT / BSD-3-Clause.  Verbatim texts are in
  `neogeorecomp/LICENSES/`.
- SDL2 — zlib license.  See `packaging/windows/SDL2.txt`.
- The MAME Neo Geo driver algorithms and constant tables used by
  `tools/decrypt.c` and `tools/tables.h` — BSD-3-Clause.  Attribution is in
  `THIRD_PARTY_NOTICES.md` and at the top of those files.
- SNK/Playmore game data, the Neo Geo BIOS, and anything generated from them.
  **None of that is distributed here.**

## Distribution caution

PolyForm Noncommercial is not an open-source license and does not permit
commercial redistribution.  Do not assume that a build of this project may be
sold, bundled with commercial hardware, or distributed for a fee.  The ROMs,
BIOS and recompiled code generated from them are not covered by this license
at all; users must supply their own legally obtained dumps.

Upstream and third-party files keep their own terms.
