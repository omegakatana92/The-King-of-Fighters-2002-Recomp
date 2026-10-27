# Project changelog

## 0.1.0 — initial KOF 2002 port

- Added the verified NGH-265 ROM layout (`src/game.c`): 1 MB fixed + 4 MB
  banked program, 64 MB C-ROM sprite region, embedded 128 KB S-ROM, CMC50
  M1 and two 8 MB V-ROMs.
- Added `tools/decrypt.c`: NEO-PCM2 P-ROM block swap, NEO-CMC 7050 graphics
  decryption with the `0xEC` key, S-ROM extraction, CMC50 M1 decryption and
  NEO-PCM2 V-ROM descrambling.  Input and output CRCs are verified.
- Added the Windows and Linux CMake builds, the 16-file generated-C layout,
  the `profile` target and the AppImage packaging script.
- Wired the game to the neogeorecomp v0.2.0 runtime/recompiler source
  (upstream commit `af96b2b4...`) and the generic runtime extensions from the
  sibling Garou snapshot (watchdog, fullscreen, fixed-layer selectors,
  program bank map, NEO-SMA random latch).

## Audio repair (KOF 2002)

The first audio pass only measured "non-silent" output; that missed the
character-select/match dropouts.  A full 9,000-frame capture (coin, start,
character select, order select, match) exposed 55 silent one-second windows,
including a 10 s gap at 102 s.

**Confirmed root cause: the old M1 bank mapping in `audio.c`.**  For every
banked M1 window the code used

```c
reg_mask = (size - 0x10000 - 1) & 0x3FFFF;
off = 0x10000 + ((s_bank & reg_mask) + (a & win_mask));
```

That is wrong for the M1 layout.  MAME's `init_audio()` places the M1 file
at region offset `0x10000` via `ROM_RELOAD`, so the file offset is the
masked value alone; the address mask is `(M1 size - 1) & 0x3FFFF`, not
`size - 0x10000 - 1`.  The old `+0x10000` shifts the low bank set
(`0F000/0E000/0C000/08000`) to `1F000/1E000/1C000/18000`, reading the wrong
64 KB half of the driver's music/SFX data.  High banks happened to map
correctly, so the failure was intermittent rather than total silence.

The corrected mapping is the same one used by the repaired Garou, KOF '96,
KOF '97 and Metal Slug 3 projects:

```c
reg_mask = size ? (((uint32_t)size - 1u) & 0x3FFFFu) : 0;
off = (s_bank[w] & reg_mask) + (a & win_mask[w]);
```

The Garou repair also calls `audio_sync()` from `audio_take_samples()` so
the Z80 keeps running when the 68000 is not polling a sound port.  That
safeguard is retained, but the isolation test showed it is **not** what
fixed KOF 2002: bank-fix-only removed all 47 post-boot silent windows,
while sync-only left all 55 in place.

Measured after the bank fix (9,000-frame capture, native, interpreter and
Linux AppImage): 8 silent one-second windows, all at power-on; after 10 s
the minimum one-second RMS is 1,040.5.  `tests/check_audio.py` passes the
repaired captures and fails the pre-fix capture (10 s stop at 102 s).

## Toolkit changes made while porting

These are generic 68000 timing improvements, not KOF 2002-specific patches:

- **MULU/MULS cycle accounting.**  The emitter used the base cycle count but
  omitted the dynamic cycles: MULU adds two cycles per set bit of the
  16-bit source, and MULS adds two per bit *transition* in the sign-extended
  source.  The first `--verify` cycle report showed 10,450 blocks with 4-6
  cycle differences in BIOS delay/multiply routines, and later 112 in
  gameplay.  The emitter now emits the matching helpers
  (`ng_mulu_extra_cycles`, `ng_muls_extra_cycles`).
- **Cycle reporting in `--verify`.**  In addition to registers, flags and bus
  writes, `--verify` now counts blocks whose native cycle total differs from
  Musashi's.  It reports the first few and the total without turning a cycle
  difference into a hard mismatch.  Useful when a native screenshot differs
  from the interpreter by a few pixels at a raster boundary.

- **DBcc condition-true timing.**  A `DBcc` whose condition is true takes
  12 cycles on a 68000; the emitter was adding the counter-expired
  adjustment and charging 14.  The long `--verify` session found two such
  blocks (2 cycles each).  The emitter now charges 12 when the condition is
  true and 14 only when the counter expires.
- **SDL window robustness.**  `window_sdl.c` now reports window/texture
  creation failures and falls back to SDL's software renderer when the
  accelerated one is unavailable.  This does not change the normal
  accelerated path on Windows or Steam Deck.

All three changes are in `neogeorecomp/` and apply to every game built from
this tree.  The upstream MIT license and notices are preserved.
