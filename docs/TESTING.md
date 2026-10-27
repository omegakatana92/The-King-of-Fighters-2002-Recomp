# Testing and verification

Every claim below comes from an actual run in the build environment.  Nothing
was inferred from a successful compile alone.

## Environment

| Item | Value |
|---|---|
| Host | Windows 11 x64 |
| Windows compiler | MSVC 19.51 (Visual Studio 18 2026), Release x64 |
| CMake | 4.3.3 (Windows), 4.4.4 (Ubuntu 22.04 build) |
| SDL2 (Windows) | 2.32.10 |
| Linux | Ubuntu 22.04.5 under WSL2, gcc 11.4 |
| BIOS | `sp-s2.sp1` (MVS Asia/Europe v2) |

## 1. ROM validation

`kof2002_decrypt` checks the input CRCs before doing anything and verifies
the known-good output CRCs afterwards.  All 17 known CRCs match; the M1
output is checked for size and non-empty content.  Full tables:
`docs/ROM-VALIDATION.md`.

## 2. Interpreted boot

```
KOF 2002.exe --headless --interp --rom-path build-windows\roms --frames 2000 \
  --screenshot 600:shots/interp_0600.png \
  --screenshot 1200:shots/interp_1200.png \
  --screenshot 1800:shots/interp_1800.png
```

Observed: Playmore logo at frame 600, KOF 2002 title/attract at 1200 and
1800.  The fixed layer, sprites and palette render; no ROM/BIOS error.

## 3. Interpreted gameplay path

```
KOF 2002.exe --headless --interp --rom-path build-windows\roms --frames 9000 \
  --input tests/play_select.txt --screenshot 7500:shots/ps_7500.png
```

Observed: coin/start, character select (P1 Kyo), order select, then a match
(Kyo/Benimaru/Daimon vs. the CPU team) with health bars, timer and stage.
This proves the board model, controls, menus and the match renderer before
native code is involved.

## 4. Native boot and `--verify`

```
KOF 2002.exe --headless --verify --rom-path build-windows\roms --frames 2000
```

```
[verify] 1087599 blocks checked, 0 mismatches
[exec] native blocks 1087599, native instructions 38483146,
       interpreted instructions 38 (100.00% native), 0 uncovered entry points
```

No cycle-count differences were reported.  The 38 interpreted instructions
are a routine copied to work RAM; it has no ROM entry point to recompile.
The 3,000-frame boot is also 100.00% native, 38 interpreted, 0 uncovered.

## 5. Native gameplay and long session

```
KOF 2002.exe --headless --verify --rom-path build-windows\roms --frames 9000 \
  --input tests/play_select.txt --screenshot 7500:shots/FINAL2_match_7500.png
```

```
[verify] 6413253 blocks checked, 0 mismatches
[exec] native blocks 6413253, native instructions 166089048,
       interpreted instructions 76 (100.00% native), 0 uncovered entry points
```

The longer scripted session used by the profile target:

```
KOF 2002.exe --headless --verify --rom-path build-windows\roms --frames 19000 \
  --input tests/play.txt
```

```
[verify] 12499080 blocks checked, 0 mismatches
[exec] native blocks 12499080, native instructions 353410740,
       interpreted instructions 179165 (99.95% native), 141 uncovered entry points
```

The 19,000-frame run is 99.95% native.  The 179,165 interpreted instructions
are the work-RAM routine plus 141 runtime-only entry points from idle/attract
or menu paths the profile pass did not seed.  They execute correctly in
Musashi; they are not miscompiled code.  No cycle-count differences were
reported in any of the three final runs.

## 6. Native vs interpreted frames

Ten frames from a no-input boot were rendered by both engines and compared
pixel by pixel:

| Frame | Different pixels |
|---:|---:|
| 300 | 0 |
| 600 | 0 |
| 900 | 0 |
| 1200 | 4 |
| 1500 | 0 |
| 1800 | 0 |
| 2100 | 0 |
| 2400 | 0 |
| 2700 | 0 |
| 3000 | 0 |

At frame 1200 three pixels at `(192..194, 60)` and one at `(194, 61)` differ:
the interpreter draws a white highlight, the native build leaves the
background colour.  `--verify` still reports zero register/flag/bus
mismatches and zero cycle differences.  This is the block scheduler's
raster-boundary trade-off: native code yields at loop back-edges, while the
interpreter stops exactly at the event.  A VRAM write can therefore land on
the other side of one scanline.  It is reported here rather than hidden.

Nine of ten sampled frames are byte-identical.  The Windows native build and
the Linux AppImage produced byte-identical frames at 1200, so the difference
is native-vs-interpreter, not Windows-vs-Linux.

## 7. Audio

The first pass only checked that sound existed; it missed dropouts at scene
transitions.  The decisive test is a 9,000-frame WAV through coin, start,
character select, order select and the match, analysed in one-second RMS
windows.  A window below 80 RMS counts as silent.

| Build | Silent windows | Longest silence | Minimum RMS after 10 s |
|---|---:|---:|---:|
| Before repair | 55 | 10 s at 102 s | 0.0 |
| Bank mask fixed, old pull path | 8 (power-on only) | 8 s at 0 s | 1,040.5 |
| Old bank mask, `audio_sync()` added | 55 | 10 s at 102 s | 0.0 |
| Both fixes (final) | 8 (power-on only) | 8 s at 0 s | 1,040.5 |

Native, interpreter and the Linux AppImage all give the final row; the
Linux capture is 152.06 s, 55,555 Hz stereo, max RMS 7,056.4.  The pre-fix
capture failed a 10 s stop at 102 s and had silent windows at 35-40 s,
75-85 s, 100-112 s and 145-152 s.  The fixed trace shows the driver's low
bank set (`0F000/0E000/0C000/08000`) and high bank set
(`17000/16000/14000/10000`); the old code shifted every low bank by
`+0x10000`, reading the wrong 64 KB half.

A match with scripted attacks has a higher high-frequency median (608.4 vs
348.1 for the no-input match) and more transient peaks (402 vs 322), so
attack/voice energy is present on top of continuous music.  The 19,000-frame
capture reaches GAME OVER around frame 16,000 and then the title/attract
screen; audio resumes after that transition.  There is no permanent stop.
Multiple consecutive matches and victory music were not separately
exercised.  The mix was not auditioned by a human in this environment.

Regression check:

```
python tests/check_audio.py audio_tests/final2_native.wav
python tests/check_audio.py audio_tests/final2_interp.wav
python tests/check_audio.py audio_tests/final2_linux.wav
```

All pass with `0` silent windows after the 10 s boot allowance.  The same
check on `audio_tests/before_native.wav` fails with the 10 s stop.

## 8. Windows executable

- Native windowed run, SDL2 2.32.10: 400 frames, 100.00% native, screenshot
  written, exit 0.
- The packaged folder `dist/windows/KOF 2002-Windows-x64/` was launched with
  `--headless`, 1,500 frames, 100.00% native; it loaded its local `SDL2.dll`
  and `vcruntime140*.dll`.
- `dumpbin /dependents` shows only SDL2, the MSVC runtime, UCRT and system
  DLLs.  No MSVCP140 import is needed.
- The zip and `SHA256SUMS.txt` are in `dist/windows/`.

## 9. Linux and AppImage

- gcc 11.4 Release build completed.
- `--verify` (2,000 frames): `1,087,644 blocks, 0 mismatches`, 100.00%
  native, 0 uncovered; no cycle differences.
- The 9,000-frame AppImage WAV passes `tests/check_audio.py` with zero
  post-boot silent windows; it is 152.06 s at 55,555 Hz stereo.
- AppImage built with appimagetool; `file` reports an ELF 64-bit x86-64
  executable (20.1 MB).
- `ldd` with the AppDir's `usr/lib` resolves `libSDL2-2.0.so.0` to the
  bundled copy.  The remaining libraries are standard system libs
  (`libstdc++`, `libc`, libX11/Wayland, ALSA/PulseAudio).
- Headless launch through the AppImage reaches 100.00% native; the frame it
  writes is byte-identical to the Windows native build.
- `KOF2002_ROM_DIR` discovery through `AppRun` works.
- Fullscreen/windowed run under Xvfb at 1280x800: 400 frames, 100.00%
  native, screenshot written.  `AppRun` automatically added `--fullscreen`.
- The AppImage contains `AppRun`, `kof2002.desktop`, `kof2002.png`,
  `.DirIcon`, `usr/bin/KOF2002`, `usr/bin/kof2002_decrypt`, the bundled SDL2
  and the license texts.
- A windowed WSLg session did not produce a frame in this environment; the
  Xvfb run is the validated Linux window path.  This is not a physical Deck
  test.

## 10. Generic toolkit regression

- `ng_conformance`: **59/60** 68000 test programs pass recompiled (the
  reference interpreter also passes 59/60; `move.bin` uses a 68020 mode).
- `ng_gamepad_test`: all checks pass with SDL virtual pads (player 1, player
  2, hot-unplug).
- The MULU/MULS and DBcc timing changes are covered by the cycle report in
  `--verify` and by the KOF 2002 long session.

## 11. Steam Deck

**Not tested on physical hardware.**  Gaming Mode, Steam Input, the
1280x800/OLED panel, suspend/resume and the Deck's built-in controls remain
unverified on a real unit.  The AppImage was exercised in a Linux VM with a
virtual 1280x800 display.

## 12. Determinism

Repeated runs with the same input produce byte-identical screenshots per
engine.  Windows native and the Linux AppImage produce byte-identical frames
at the sampled frame.  The only known engine difference is the four-pixel
raster-boundary case above.
