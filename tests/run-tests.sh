#!/usr/bin/env bash
# run-tests.sh - deterministic headless checks for a built Linux player.
# Usage: ./tests/run-tests.sh [PLAYER] [ROM_DIR]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAYER="${1:-$ROOT/build-linux/KOF 2002}"
ROMS="${2:-$ROOT/build-linux/roms}"
OUT="${OUT:-$ROOT/shots}"
mkdir -p "$OUT"

echo "== interpreted boot =="
"$PLAYER" --headless --interp --rom-path "$ROMS" --frames 2000 \
  --screenshot "600:$OUT/interp_0600.png" \
  --screenshot "1200:$OUT/interp_1200.png" \
  --screenshot "1800:$OUT/interp_1800.png"

echo "== native boot + verify =="
"$PLAYER" --headless --verify --rom-path "$ROMS" --frames 2000

echo "== native gameplay + verify =="
"$PLAYER" --headless --verify --rom-path "$ROMS" --frames 9000 \
  --input "$ROOT/tests/play_select.txt" \
  --screenshot "7500:$OUT/native_match.png"

echo "== audio =="
"$PLAYER" --headless --rom-path "$ROMS" --frames 2000 \
  --input "$ROOT/tests/coin_late.txt" --wav "$OUT/test_audio.wav"

echo "All headless checks completed."
