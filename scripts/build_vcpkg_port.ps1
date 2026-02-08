
<#
.SYNOPSIS
    Generates a vcpkg registry port for abcmake with the correct SHA512 hash.

.DESCRIPTION
    Downloads the GitHub source tarball for a given tag, computes its SHA512,
    and writes a ready-to-use portfile.cmake + vcpkg.json into dist/vcpkg-port/.

    Can be run locally or from CI.

.PARAMETER Tag
    The git tag to build the port for (e.g. "v6.4.0").
    Defaults to the tag matching the version in src/version.cmake.

.EXAMPLE
    .\scripts\build_vcpkg_port.ps1
    .\scripts\build_vcpkg_port.ps1 -Tag v6.4.0
#>

param(
    [string]$Tag
)

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot/.."

$RepoRoot = (Resolve-Path ".").Path
$OutDir = Join-Path $RepoRoot "dist/vcpkg-port"

# Read version from source if no tag provided
if (-not $Tag) {
    $VersionLine = Get-Content (Join-Path $RepoRoot "src/version.cmake") -Raw
    if ($VersionLine -match 'set\(ABCMAKE_VERSION\s+([^\)]+)\)') {
        $Tag = "v$($Matches[1])"
    } else {
        Write-Error "Could not parse version from src/version.cmake"
        exit 1
    }
}

$Version = $Tag.TrimStart("v")
$Url = "https://github.com/an-dr/abcmake/archive/refs/tags/${Tag}.tar.gz"

Write-Host "Tag:     $Tag"
Write-Host "Version: $Version"
Write-Host "URL:     $Url"

# Download and compute SHA512
Write-Host "Downloading tarball..."
$TempFile = [System.IO.Path]::GetTempFileName()
try {
    Invoke-WebRequest -Uri $Url -OutFile $TempFile -UseBasicParsing
    $Hash = (Get-FileHash -Path $TempFile -Algorithm SHA512).Hash.ToLower()
    Write-Host "SHA512:  $Hash"
} finally {
    Remove-Item $TempFile -ErrorAction SilentlyContinue
}

# Generate output
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutDir | Out-Null

# portfile.cmake
$Portfile = @"
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-dr/abcmake
    REF "$Tag"
    SHA512 $Hash
)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "`${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "`${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "`${SOURCE_PATH}/LICENSE")
"@

Set-Content -Path (Join-Path $OutDir "portfile.cmake") -Value $Portfile -NoNewline

# vcpkg.json
$OverlayJson = Get-Content (Join-Path $RepoRoot "ports/abcmake/vcpkg.json") -Raw
$RegistryJson = $OverlayJson -replace '"version":\s*"[^"]*"', "`"version`": `"$Version`""
Set-Content -Path (Join-Path $OutDir "vcpkg.json") -Value $RegistryJson -NoNewline

Write-Host "Generated port in: $OutDir"
