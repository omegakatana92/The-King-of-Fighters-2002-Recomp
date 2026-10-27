# Steam Deck notes

The AppImage is a native Linux x86_64 build.  It is not a Windows executable
run through Proton and it is not a conventional emulator frontend.

## Installing

1. Copy `KOF 2002-SteamDeck-x86_64.AppImage` to the Deck and make it
   executable (`chmod +x`).
2. Put a prepared `roms/` folder next to it, or keep the folder elsewhere and
   pass `--rom-path`.
3. In Desktop Mode, double-click the AppImage.  In Gaming Mode, add it as a
   non-Steam game (Steam -> Games -> Add a Non-Steam Game).

The launcher starts fullscreen.  It fits the Neo Geo's 4:3 picture into the
1280x800 16:10 panel and pillarboxes; it does not stretch the image.

## Controls

The runtime reads SDL2 GameController devices.  Steam Input should present
the Deck's controls as an Xbox-compatible pad.

| Deck / Steam Input | Neo Geo |
|---|---|
| D-pad or left stick | joystick |
| A / B / X / Y | A / B / C / D |
| Start | 1P start |
| View / Back | coin |
| Left bumper | select |
| Steam button -> Exit | quit |

If Steam Input uses a layout that does not expose View/Back, map a back
button (L4/L5/R4/R5) to `Back` in the controller layout.  Coin is required
before Start does anything on an MVS BIOS.

Keyboard fallback: arrows, Z/X/C/V, 5 (coin), 1/2 (start), F11 (fullscreen),
Esc (quit).

## Launch options

```
--rom-path "/home/deck/Emulation/roms/kof2002" --fullscreen
```

`--rom-path` is optional when the ROM folder is next to the AppImage.  Use
`--mute` for a quiet test and `--headless` for a non-graphical smoke test.

## Performance

The game runs natively at the MVS refresh rate (59.1856 Hz).  The renderer
is SDL2 accelerated, the audio device is opened at the YM2610 rate and SDL
resamples.  No frame interpolation or stretching is performed.

## Verification status

- Built with gcc 11.4 on Ubuntu 22.04 x86_64.
- AppImage assembled with appimagetool and launched headless and fullscreen
  under Xvfb at 1280x800 (400 frames, 100.00% native).
- The Windows native build and the Linux AppImage produce byte-identical
  frames at the sampled frame.
- **Not tested on physical Steam Deck hardware.**  Gaming Mode, Steam Input,
  suspend/resume, the OLED panel and the Deck's built-in controls still need
  validation on a real unit.  This limitation is stated in the README and the
  AppImage's own README.
