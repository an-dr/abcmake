$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot/.."

$RepoRoot = (Resolve-Path ".").Path
$BuildDir = Join-Path $RepoRoot "build/package"
$Prefix   = Join-Path $RepoRoot "dist/package"
$Config   = "Release"
$Generator = "Ninja"

Write-Host "? Configure"
cmake -S $RepoRoot -B $BuildDir -DCMAKE_INSTALL_PREFIX="$Prefix" -DCMAKE_BUILD_TYPE=$Config -G $Generator
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "? Build"
cmake --build "$BuildDir" --config $Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "? Install"
cmake --install "$BuildDir" --config $Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "? Installed to $Prefix"
