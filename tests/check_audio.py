#!/usr/bin/env python3
"""check_audio.py - regression check for a KOF 2002 capture.

Fails if the capture has a sustained silent stretch after power-on.  The
BIOS boot is silent for a few seconds, so the first --boot seconds are
ignored.  This catches the class of bug where the M1 bank mapping or the
Z80 sequencer stops feeding music/SFX after a scene transition.

Usage:
  python3 tests/check_audio.py capture.wav [--boot 10] [--min-rms 200]

Exit status 0 on pass, 1 on failure.
"""
import argparse
import array
import math
import sys
import wave


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("wav")
    ap.add_argument("--boot", type=float, default=10.0,
                    help="seconds at the start that may be silent")
    ap.add_argument("--min-rms", type=float, default=200.0,
                    help="minimum RMS for a one-second window after boot")
    ap.add_argument("--max-silence", type=float, default=1.5,
                    help="longest allowed silent run after boot, seconds")
    args = ap.parse_args()

    w = wave.open(args.wav, "rb")
    rate = w.getframerate()
    ch = w.getnchannels()
    n = w.getnframes()
    samples = array.array("h")
    samples.frombytes(w.readframes(n))

    windows = []
    for s in range(0, n, rate):
        seg = samples[s * ch:(s + rate) * ch]
        if not seg:
            break
        windows.append(math.sqrt(sum(x * x for x in seg) / len(seg)))

    boot = int(args.boot)
    after = windows[boot:]
    if not after:
        print("FAIL: capture shorter than the boot window")
        return 1

    silent = [i + boot for i, v in enumerate(after) if v < args.min_rms]
    longest = 0
    run = 0
    start = 0
    best_start = 0
    for i, v in enumerate(after):
        if v < args.min_rms:
            if run == 0:
                start = i + boot
            run += 1
            if run > longest:
                longest = run
                best_start = start
        else:
            run = 0

    print("file:              %s" % args.wav)
    print("format:            %d Hz, %d ch, %.2f s" %
          (rate, ch, n / float(rate)))
    print("windows after boot:%d" % len(after))
    print("minimum RMS:       %.1f" % min(after))
    print("maximum RMS:       %.1f" % max(after))
    print("silent windows:    %d" % len(silent))
    print("longest silence:   %d s at %d s" % (longest, best_start))

    if longest > args.max_silence:
        print("FAIL: audio stops for %d s after boot" % longest)
        return 1
    if min(after) < args.min_rms:
        print("FAIL: a one-second window after boot is below %.1f RMS" %
              args.min_rms)
        return 1
    print("PASS: continuous audio after the boot window")
    return 0


if __name__ == "__main__":
    sys.exit(main())
