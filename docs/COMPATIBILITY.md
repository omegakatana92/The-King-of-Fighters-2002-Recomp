# Hardware and ROM compatibility

## Cartridge

*The King of Fighters 2002* is an MVS/AES release on the NGH-265 cartridge.
MAME's `kof2002` set describes it as:

- **NEO-MVS PROGBK2** program board with the **NEO-PCM2** (Playmore 2002)
  protection chip.
- **NEO-MVS CHAFIO** with a **NEO-CMC 7050** graphics chip.

The program board is 1 MB of fixed code plus a 4 MB banked image.  The
cartridge header at `$100` of the fixed bank reads `NEO-GEO` after the P ROM
word swap.  The reset vectors point at the BIOS (`$00C00402` in the verified
dump), so the real MVS system ROM performs the boot.

## ROM set used

The supplied archive is a merged MAME set.  The parent `kof2002` files were
validated by SHA1 and CRC32 against MAME:

| File | Size | CRC32 | Role |
|---|---:|---|---|
| `265-p1.p1` | 1 MB | `9ede7323` | fixed 68k code |
| `265-p2.sp2` | 4 MB | `327266b8` | banked 68k code, PCM2 block order |
| `265-c1.c1` .. `265-c8.c8` | 8 MB each | see `tools/decrypt.c` | CMC 7050 sprite planes |
| `265-m1.m1` | 128 KB | `85aaa632` | CMC50-encrypted Z80 program |
| `265-v1.v1` | 8 MB | `15e8f3f5` | PCM2-scrambled ADPCM |
| `265-v2.v2` | 8 MB | `da41d6f9` | PCM2-scrambled ADPCM |

There is **no `265-s1.s1` in the original set**.  On the encrypted CHAFIO
boards the fixed-layer data is stored at the end of the C ROM data; the
preparation tool extracts the 128 KB S ROM (`e0eaaba3`) exactly as MAME's
`sfix_decrypt()` does.

The system set used is `neogeo.zip`: `sp-s2.sp1` (MVS Asia/Europe v2),
`sfix.sfix`, `sm1.sm1` and `000-lo.lo`.  Other BIOS revisions can be selected
with `--bios`, but only `sp-s2.sp1` was tested.

## Protection and how it is handled

All three protections are removed **at build time**, in
`tools/decrypt.c`, so the runtime sees plain files:

1. **NEO-PCM2 program block swap.**  The 4 MB banked image is reordered in
   eight 512 KB blocks.  The table is MAME's `kof2002_decrypt_68k()`.  This
   is a data permutation only; the cartridge still uses the standard 1 MB
   banking window at `$2FFFF0` afterwards.
2. **NEO-CMC 7050 graphics.**  The eight C ROMs are interleaved, decrypted
   with the CMC50/KOF2000 tables and KOF2002's `0xEC` address key, and the
   embedded S ROM is extracted.  Results match the known decrypted C/S CRCs.
3. **CMC50 M1.**  The Z80 program is decrypted with the checksum-derived key
   (`0x95F3` for this dump), using MAME's `cmc50_m1_decrypt()` address
   scramble.
4. **NEO-PCM2 V ROMs.**  The 16 MB V image is descrambled with MAME's
   `pcm2_prot_device::swap(..., 0)` address permutation and XOR table.

The runtime therefore needs no per-title protection hooks.  `game.c` names
the prepared files and sets `fix_bank_type = NG_FIX_BANK_NONE` (plain 128 KB
fix layer) and a standard 1 MB program bank map.

The M1 bank mapping is the one shared audio path that needed a correction.
MAME places the M1 file at region offset `0x10000` via `ROM_RELOAD`, so the
Z80 bank window offset is `(M1 size - 1) & 0x3FFFF` with no extra base.  The
old `(size - 0x10000 - 1)` mask plus `+0x10000` shifted the low bank set
(`0F000/0E000/0C000/08000`) into the wrong 64 KB half; music and SFX dropped
out at scene transitions.  The repaired mapping is used here and in the
repaired Garou/KOF '96/KOF '97/Metal Slug 3 projects.

## Board features exercised

| Feature | Status in this build |
|---|---|
| 68000 static recompilation | 50,122 dispatch entries from static discovery; 778 runtime-only entries found by profiling |
| MVS BIOS boot | Real `sp-s2.sp1`; memory test, eye-catcher, coin/start |
| P ROM banking | Standard `$2FFFF0` 1 MB window |
| Sprite renderer | Per-scanline L0 shrink, sticky chains, 96/line limit |
| Fixed layer | 128 KB S ROM, plain fix map |
| Palettes / raster | Both palette banks; raster timer IRQ observed |
| Z80 | Real CMC50-decrypted M1 driver, NMI/reply latches |
| YM2610 | FM, SSG and ADPCM-A/B through ymfm |
| Input | Keyboard and SDL2 GameController; coin/start/service/test |
| Watchdog | Generic MVS watchdog reset implemented |
| Backup RAM | Modelled, with lock behaviour |
| uPD4990A calendar | Modelled |

## Not claimed

- No physical MVS/AES hardware comparison was made.
- No physical Steam Deck or gamepad was available.
- The full move list, every character, every stage, endings, continue and
  two-player paths were not exhaustively played.  See `TESTING.md` for the
  exact session that was recorded.
- The build does not include ROMs, BIOS files, or recompiled output.
