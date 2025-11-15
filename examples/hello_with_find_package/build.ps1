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

# The script builds the "hello_with_find_package" example project.

# Define paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectDir = Join-Path $scriptDir "."
$buildDir = Join-Path $projectDir "build" 

# Create build directory if it doesn't exist
if (-Not (Test-Path -Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}   

# Change to build directory
Set-Location -Path $buildDir    
# Run CMake to configure and build the project with Ninja generator
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release $projectDir
cmake --build . --config Release

# Return to the original script directory
Set-Location -Path $scriptDir
Write-Host "Build completed successfully."
