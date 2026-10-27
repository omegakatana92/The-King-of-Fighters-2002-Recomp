# package-windows.ps1 - assemble dist/windows/KOF 2002-Windows-x64 from a
# Release build.  ROMs are never copied: the user supplies their own.
param(
    [string]$BuildDir = "",
    [string]$ProjectDir = ""
)

$ErrorActionPreference = "Stop"
if (-not $ProjectDir) {
    $ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}
if (-not $BuildDir) { $BuildDir = Join-Path $ProjectDir "build-windows" }

$rel = Join-Path $BuildDir "Release"
$exe = Join-Path $rel "KOF 2002.exe"
if (-not (Test-Path $exe)) { throw "Missing $exe; build the Release player first" }

$out = Join-Path $ProjectDir "dist\windows\KOF 2002-Windows-x64"
if (Test-Path $out) { Remove-Item -Recurse -Force $out }
New-Item -ItemType Directory -Force $out | Out-Null
New-Item -ItemType Directory -Force (Join-Path $out "LICENSES") | Out-Null

Copy-Item $exe $out
Copy-Item (Join-Path $rel "kof2002_decrypt.exe") $out
Copy-Item (Join-Path $rel "SDL2.dll") $out
Copy-Item (Join-Path $ProjectDir "packaging\windows\README.txt") $out
Copy-Item (Join-Path $ProjectDir "packaging\windows\Prepare-ROMs.ps1") $out
Copy-Item (Join-Path $ProjectDir "packaging\windows\SDL2.txt") (Join-Path $out "LICENSES\SDL2.txt")

# MSVC runtime: ship the DLLs next to the exe so a fresh Windows install
# without the VC++ redistributable can run it.
foreach ($dll in @("vcruntime140.dll", "vcruntime140_1.dll")) {
    $candidates = @()
    $systemDll = Join-Path $env:WINDIR "System32\$dll"
    if (Test-Path $systemDll) { $candidates += $systemDll }
    if ($env:VCToolsRedistDir) {
        $redistDll = Join-Path $env:VCToolsRedistDir "x64\Microsoft.VC143.CRT\$dll"
        if (Test-Path $redistDll) { $candidates += $redistDll }
    }
    if ($candidates.Count -gt 0) { Copy-Item $candidates[0] $out }
    else { Write-Warning "Could not find $dll; the target needs the VC++ 2015-2022 runtime" }
}

Copy-Item (Join-Path $ProjectDir "LICENSE") (Join-Path $out "LICENSES\LICENSE.txt")
Copy-Item (Join-Path $ProjectDir "LICENSE-STATUS.md") (Join-Path $out "LICENSES\LICENSE-STATUS.txt")
Copy-Item (Join-Path $ProjectDir "THIRD_PARTY_NOTICES.md") (Join-Path $out "LICENSES\THIRD_PARTY_NOTICES.txt")
Copy-Item (Join-Path $ProjectDir "neogeorecomp\LICENSE") (Join-Path $out "LICENSES\neogeorecomp.txt")
Copy-Item (Join-Path $ProjectDir "neogeorecomp\NOTICE") (Join-Path $out "LICENSES\neogeorecomp-NOTICE.txt")
Get-ChildItem (Join-Path $ProjectDir "neogeorecomp\LICENSES\*.txt") | Copy-Item -Destination (Join-Path $out "LICENSES")

# Hashes, computed after every file is in place.
$lines = Get-ChildItem $out -Recurse -File | Where-Object { $_.Name -ne "SHA256SUMS.txt" } |
    Sort-Object FullName | ForEach-Object {
        $relPath = $_.FullName.Substring($out.Length + 1).Replace('\', '/')
        "{0}  {1}" -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower(), $relPath
    }
Set-Content -Path (Join-Path $out "SHA256SUMS.txt") -Value $lines -Encoding ASCII

$zip = Join-Path $ProjectDir "dist\windows\KOF 2002-Windows-x64.zip"
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path $out -DestinationPath $zip
Write-Host "wrote $out"
Write-Host "wrote $zip"
