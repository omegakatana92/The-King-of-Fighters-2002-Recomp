# Prepare-ROMs.ps1 - build a runtime-ready KOF 2002 ROM set from your own dumps.
#
# This script extracts the MAME "kof2002" and "neogeo" sets and runs the
# bundled decrypt tool.  It downloads nothing and contains no ROM data.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\Prepare-ROMs.ps1
#   powershell -ExecutionPolicy Bypass -File .\Prepare-ROMs.ps1 -KofZip C:\path\kof2002.zip -NeoGeoZip C:\path\neogeo.zip

param(
    [string]$KofZip = "",
    [string]$NeoGeoZip = "",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $OutDir) { $OutDir = Join-Path $here "roms" }
$src = Join-Path $here "roms-src"

function Ask-Zip($label, $current) {
    if ($current -and (Test-Path $current)) { return (Resolve-Path $current).Path }
    while ($true) {
        $p = Read-Host "Path to $label"
        $p = $p.Trim('"').Trim()
        if (Test-Path $p) { return (Resolve-Path $p).Path }
        Write-Host "Not found: $p" -ForegroundColor Yellow
    }
}

$KofZip = Ask-Zip "kof2002.zip" $KofZip
$NeoGeoZip = Ask-Zip "neogeo.zip" $NeoGeoZip

if (-not (Test-Path (Join-Path $here "kof2002_decrypt.exe"))) {
    throw "kof2002_decrypt.exe is missing from $here"
}

if (Test-Path $src) { Remove-Item -Recurse -Force $src }
New-Item -ItemType Directory -Force $src | Out-Null
New-Item -ItemType Directory -Force $OutDir | Out-Null

# Merged MAME sets put the parent files in a kof2002/ subdirectory.  Extract
# to a scratch folder, find the parent set, and flatten only the files the
# tool needs.  This also works for a non-merged zip with the files at the root.
$gameScratch = Join-Path $src "game"
New-Item -ItemType Directory -Force $gameScratch | Out-Null
Write-Host "Extracting $KofZip"
tar -xf $KofZip -C $gameScratch
if ($LASTEXITCODE -ne 0) { throw "Could not extract kof2002.zip with tar" }
$p1 = Get-ChildItem $gameScratch -Recurse -Filter "265-p1.p1" | Select-Object -First 1
if (-not $p1) { throw "265-p1.p1 was not found in $KofZip" }
$gameDir = $p1.DirectoryName
$needed = @("265-p1.p1", "265-p2.sp2",
            "265-c1.c1", "265-c2.c2", "265-c3.c3", "265-c4.c4",
            "265-c5.c5", "265-c6.c6", "265-c7.c7", "265-c8.c8",
            "265-m1.m1", "265-v1.v1", "265-v2.v2")
foreach ($name in $needed) {
    $f = Join-Path $gameDir $name
    if (-not (Test-Path $f)) { throw "$name is missing from the kof2002 set" }
    Copy-Item $f (Join-Path $src $name)
}
Remove-Item -Recurse -Force $gameScratch

Write-Host "Extracting $NeoGeoZip"
tar -xf $NeoGeoZip -C $src
if ($LASTEXITCODE -ne 0) { throw "Could not extract neogeo.zip with tar" }

Write-Host "Preparing KOF 2002 ROMs"
& (Join-Path $here "kof2002_decrypt.exe") --rom-path $src --out $OutDir
if ($LASTEXITCODE -ne 0) { throw "kof2002_decrypt failed" }

Write-Host ""
Write-Host "Done. Run:" -ForegroundColor Green
Write-Host "  .\`"KOF 2002.exe`" --rom-path `"$OutDir`""
