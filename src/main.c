/*
 * main.c - The King of Fighters 2002 player.
 *
 * The board model, the interpreter fallback, the window and the audio live
 * in neogeorecomp.  This file hands the runtime the cart's ROM layout and,
 * when the build generated it from the user's own dump, the native dispatch
 * table.  Without that table the runtime interprets.
 */
#include "game.h"
#include <stddef.h>

#ifdef KOF2002_HAVE_RECOMP
extern const ng_func_entry_t ng_recomp_table[];
extern const size_t ng_recomp_count;
#endif

int main(int argc, char **argv) {
#ifdef KOF2002_HAVE_RECOMP
    return ng_main(argc, argv, &k_kof2002, ng_recomp_table, ng_recomp_count);
#else
    return ng_main(argc, argv, &k_kof2002, NULL, 0);
#endif
}
