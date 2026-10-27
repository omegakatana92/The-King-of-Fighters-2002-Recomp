THE KING OF FIGHTERS 2002 - Steam Deck / Linux x86_64
====================================================

This AppImage contains a native static recompilation of KOF 2002 built with
neogeorecomp v0.2.0.  It is not a Windows executable in a wrapper and it is
not a conventional emulator frontend: the 68000 program is recompiled to C
and runs natively, with Musashi as the fallback for addresses that were not
reached during profiling.

ROMs
----
No game or BIOS data is bundled.  Put a prepared ROM folder in one of these
places, or pass --rom-path:

  * next to the AppImage:  roms/  or  roms/kof2002/
  * $HOME/Emulation/roms/kof2002/
  * $HOME/roms/kof2002/
  * $HOME/roms/
  * $KOF2002_ROM_DIR

A prepared folder contains 265-p1.p1, 265-p2.sp2, 265-c1..c8, 265-s1.s1,
265-m1.m1, 265-v1/v2 and the four system ROM files.  If you point the
launcher at an original encrypted set (265-p2.sp2 + 265-m1.m1, no
265-s1.s1), it prepares a copy under ~/.local/share/kof2002/roms once.

Launching
---------
Desktop Mode: make the AppImage executable and double-click it, or run

  ./KOF\ 2002-SteamDeck-x86_64.AppImage --rom-path /path/to/roms

Gaming Mode: add the AppImage as a non-Steam game.  Steam Input should expose
it as an Xbox-compatible controller.  The launcher starts fullscreen (4:3
pillarboxed on the 16:10 panel; it never stretches the picture) unless you
pass --scale or --headless.

  Keyboard              Neo Geo
  ------------------------------------------------
  Arrow keys            joystick
  Z X C V               A B C D
  5                     coin
  1 / 2                 start (P1 / P2)
  3                     select
  F11                   toggle fullscreen
  Esc                   quit

  Gamepad (Xbox layout)
  ------------------------------------------------
  D-pad / left stick    joystick
  A B X Y               A B C D
  Start                 start
  Back / View           coin
  Left shoulder         select

If your pad is not recognised, set SDL_GAMECONTROLLERCONFIG to an SDL mapping
string.  In Gaming Mode, Steam Input can also map the Deck's back buttons.

Options
-------
  --rom-path DIR        prepared ROM directory
  --bios FILE           system ROM (default: sp-s2.sp1)
  --headless            no window
  --frames N            stop after N frames
  --screenshot N:FILE   save a frame as PNG
  --input FILE          scripted input
  --interp              run everything in Musashi
  --verify              replay native blocks in Musashi and compare
  --scale N             window scale
  --fullscreen          fullscreen, 4:3 letterboxed
  --mute / --wav FILE   sound control

Status and limitations
----------------------
  * Built and launched headless and fullscreen under Xvfb at 1280x800 in a
    Linux x86_64 VM.  **Not tested on physical Steam Deck hardware**, so
    Gaming Mode and Steam Input remain unverified on a real Deck.
  * Music/SFX continuity is measured through character select and a match
    after the M1 bank-mapping repair; the mix was not auditioned by ear.
  * The full game has not been exhaustively played.  See README.md in the
    source tree for the measured coverage and the tested path.
  * 1280x800: the image is pillarboxed to 4:3, matching the original CRT
    presentation.  No unintended stretching.

Licenses
--------
PolyForm Noncommercial 1.0.0 applies only to the original project code.  neogeorecomp is MIT; Musashi and z80 are MIT; ymfm
and the MAME Neo Geo driver references are BSD-3-Clause; SDL2 is zlib.
Full texts: usr/share/doc/kof2002/LICENSES/ inside the AppImage.  The game
and BIOS are not licensed or distributed here.
