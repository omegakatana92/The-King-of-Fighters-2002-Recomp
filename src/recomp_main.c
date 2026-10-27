/*
 * recomp_main.c - kof2002_recomp, the generator: reads the decrypted ROM
 * files and writes the recompiled C into the build tree.
 */
#include <neogeorecomp/recomp.h>
#include "game.h"

int main(int argc, char **argv) { return ng_recomp_main(argc, argv, &k_kof2002); }
