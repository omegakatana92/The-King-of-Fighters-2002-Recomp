/*
 * game.c - The King of Fighters 2002 (MAME set "kof2002") ROM layout.
 *
 * The cartridge is the retail encrypted MVS/AES release (NGH-265).  The
 * program is 1 MB of fixed code plus a 4 MB banked image; the banked image's
 * 512 KB blocks are permuted by the NEO-PCM2 program path.  Graphics are
 * NEO-CMC 7050 encrypted and carry the 128 KB fixed layer at the end of the
 * C data, so there is no separate S-ROM in the original set.  Audio is a
 * CMC50-encrypted 128 KB M1 and two 8 MB NEO-PCM2-scrambled V ROMs.
 *
 * tools/decrypt.c performs all of that at build time.  This structure names
 * only the runtime-ready files it writes, so the player and the recompiler
 * load the program identically.  P ROMs are stored byte-swapped (MAME's
 * ROM_LOAD16_WORD_SWAP), hence swap = 1.
 */
#include "game.h"

const ng_game_t k_kof2002 = {
    .name = "kof2002",
    .title = "The King of Fighters 2002",
    .prom_size = 0x500000,           /* 1 MB fixed + 4 MB banked */
    .prom = {
        {"265-p1.p1",  0x000000, 0x000000, 0x100000, 1},
        {"265-p2.sp2", 0x000000, 0x100000, 0x400000, 1},
    },
    .crom_size = 0x4000000,          /* 64 MB after pairing */
    .crom_pairs = {
        {"265-c1.c1", "265-c2.c2"},
        {"265-c3.c3", "265-c4.c4"},
        {"265-c5.c5", "265-c6.c6"},
        {"265-c7.c7", "265-c8.c8"},
    },
    .srom = "265-s1.s1",             /* 128 KB, extracted from the C data */
    .m1 = "265-m1.m1",               /* CMC50-decrypted Z80 program */
    .vrom = {"265-v1.v1", "265-v2.v2"},
    .fix_bank_type = NG_FIX_BANK_NONE,   /* 128 KB S ROM, plain fix map */
    .bank_map = NULL,                    /* standard 1 MB P-ROM banking */
};
