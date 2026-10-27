# run-tests.ps1 - deterministic headless checks for a built Windows player.
# Usage:
#   powershell -ExecutionPolicy Bypass -File tests\run-tests.ps1 `
#       -Exe "build-windows\Release\KOF 2002.exe" -Roms "build-windows\roms"
param(
    [string]$Exe = "build-windows\Release\KOF 2002.exe",
    [string]$Roms = "build-windows\roms",
    [string]$OutDir = "shots"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force $OutDir | Out-Null

Write-Host "== interpreted boot =="
& $Exe --headless --interp --rom-path $Roms --frames 2000 `
    --screenshot "600:$OutDir/interp_0600.png" `
    --screenshot "1200:$OutDir/interp_1200.png" `
    --screenshot "1800:$OutDir/interp_1800.png"
if ($LASTEXITCODE -ne 0) { throw "interpreted boot failed" }

Write-Host "== native boot + verify =="
& $Exe --headless --verify --rom-path $Roms --frames 2000
if ($LASTEXITCODE -ne 0) { throw "native verify failed" }

Write-Host "== native gameplay + verify =="
& $Exe --headless --verify --rom-path $Roms --frames 9000 `
    --input tests\play_select.txt `
    --screenshot "7500:$OutDir/native_match.png"
if ($LASTEXITCODE -ne 0) { throw "native gameplay verify failed" }

Write-Host "== audio =="
& $Exe --headless --rom-path $Roms --frames 2000 --input tests\coin_late.txt `
    --wav "$OutDir/test_audio.wav"
if ($LASTEXITCODE -ne 0) { throw "audio run failed" }

Write-Host "All headless checks completed."
