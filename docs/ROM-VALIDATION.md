# ROM validation

The archive supplied for this project is a merged MAME set.  Only the parent
`kof2002` files and the four system files used by the runtime were extracted.
The original archive was not modified.

## Input files

| File | Size | CRC32 | SHA1 |
|---|---:|---|---|
| `265-p1.p1` | 1048576 | `9ede7323` | `ad9d45498777fda9fa58e75781f48e09aee705a6` |
| `265-p2.sp2` | 4194304 | `327266b8` | `98f445cc0a94f8744d74bca71cb420277622b034` |
| `265-c1.c1` | 8388608 | `2b65a656` | `9c46d8cf5b1ef322db442ac6a9b9406ab49206c5` |
| `265-c2.c2` | 8388608 | `adf18983` | `150cd4a5e51e9df88688469d2ea7675c2cf3658a` |
| `265-c3.c3` | 8388608 | `875e9fd7` | `28f52d56192d48bbc5dc3c97abf456bd34a58cbd` |
| `265-c4.c4` | 8388608 | `2da13947` | `f8d79ec2c236aa3d3648a4f715676899602122c1` |
| `265-c5.c5` | 8388608 | `61bd165d` | `b3424db84bc683d858fb635bc42728f9cdd89caf` |
| `265-c6.c6` | 8388608 | `03fdd1eb` | `6155c7e802062f4eafa27e414c4e73ee59b868bf` |
| `265-c7.c7` | 8388608 | `1a2749d8` | `af7d9ec1d576209826fa568f676bbff92f6d6ddd` |
| `265-c8.c8` | 8388608 | `ab0bb549` | `d23afb60b7f831f7d4a98ad3c4a00ee19877a1ce` |
| `265-m1.m1` | 131072 | `85aaa632` | `744fba4ca3bc3a5873838af886efb97a8a316104` |
| `265-v1.v1` | 8388608 | `15e8f3f5` | `7c9e6426b9fa6db0158baa17a6485ffce057d889` |
| `265-v2.v2` | 8388608 | `da41d6f9` | `a43021f1e58947dcbe3c8ca5283b20b649f0409d` |

The game set has **no S ROM**.  That is correct for the encrypted CHAFIO
board: the fixed-layer data is embedded at the end of the C ROMs.

## System files (from `neogeo.zip`)

| File | Size | CRC32 | SHA1 |
|---|---:|---|---|
| `sp-s2.sp1` | 131072 | `9036d879` | `4f5ed7105b7128794654ce82b51723e16e389543` |
| `sfix.sfix` | 131072 | `c2ea0cfd` | `fd4a618cdcdbf849374f0a50dd8efe9dbab706c3` |
| `sm1.sm1` | 131072 | `94416d67` | `42f9d7ddd6c0931fd64226a60dc73602b2819dcf` |
| `000-lo.lo` | 131072 | `5a86cff2` | `5992277debadeb64d1c1c64b0a92d9293eaf7e4a` |

## Prepared output (verified by `kof2002_decrypt`)

These are the CRCs of the decrypted files.  They match the established
decrypted KOF 2002 set (and MAME's algorithms):

| File | Size | CRC32 |
|---|---:|---|
| `265-p1.p1` | 1048576 | `9ede7323` |
| `265-p2.sp2` | 4194304 | `432fdf53` |
| `265-c1.c1` | 8388608 | `7efa6ef7` |
| `265-c2.c2` | 8388608 | `aa82948b` |
| `265-c3.c3` | 8388608 | `959fad0b` |
| `265-c4.c4` | 8388608 | `efe6a468` |
| `265-c5.c5` | 8388608 | `74bba7c6` |
| `265-c6.c6` | 8388608 | `e20d2216` |
| `265-c7.c7` | 8388608 | `8a5b561c` |
| `265-c8.c8` | 8388608 | `bef667a3` |
| `265-s1.s1` | 131072 | `e0eaaba3` |
| `265-v1.v1` | 8388608 | `0fc9a58d` |
| `265-v2.v2` | 8388608 | `b8c475a4` |
| `265-m1.m1` | 524288 | `36acf1b9` |

The M1 output has no published decrypted CRC.  Its CMC50 key is `0x95F3`;
the Z80 starts at reset, the driver answers the 68k command/reply protocol,
and the YM2610 produces non-silent output (see `TESTING.md`).

## Structural checks

- The P1 header at `$100` reads `NEO-GEO` after the word swap.
- The reset vectors are `SP=0010F300`, `PC=00C00402` (BIOS entry).
- The cartridge header at `$122` onwards contains `JMP` entries, not data.
- The decrypted M1 starts with `F3 C3 B0 00` (DI; JP $00B0), a valid Z80
  reset path.
- The V data has the expected ADPCM byte distribution, not a flat zero/FF
  fill.
