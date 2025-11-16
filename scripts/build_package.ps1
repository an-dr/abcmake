#!/usr/bin/env pwsh
# *************************************************************************
#
# Copyright (c) 2025 Andrei Gramakov. All rights reserved.
#
# This file is licensed under the terms of the MIT license.  
# For a copy, see: https://opensource.org/licenses/MIT
#
# site:    https://agramakov.me
# e-mail:  mail@agramakov.me
#
# *************************************************************************

param(
    [string]$Version = "X.X.X"
)

pushd $PSScriptRoot/..

# Build package
mkdir -Force build | Out-Null
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=dist/package -G "Ninja"
cmake --build build --config Release --target all
cmake --install build --config Release --prefix dist/package

# Create zip archive
$zipName = "abcmake-package-v$Version.zip"
$zipPath = Join-Path "dist" $zipName

Write-Host ""
Write-Host "Creating archive: $zipName" -ForegroundColor Cyan

# Remove existing zip if present
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Create zip from package directory
Compress-Archive -Path "dist/package/*" -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "Archive created successfully: $zipPath" -ForegroundColor Green
Write-Host "Archive size: $([math]::Round((Get-Item $zipPath).Length / 1KB, 2)) KB" -ForegroundColor Gray

popd
