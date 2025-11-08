# Chocolatey Package for abcmake
# For future submission to the Chocolatey Community Repository

$ErrorActionPreference = 'Stop'

$packageName = 'abcmake'
$version = $env:ChocolateyPackageVersion
$url = "https://github.com/an-dr/abcmake/releases/download/v$version/abcmake-v$version-install.tar.gz"
$checksum = 'SHA256_PLACEHOLDER'  # Update with actual SHA256
$checksumType = 'sha256'
$installDir = Join-Path $env:ProgramFiles $packageName

# Download and extract package
$packageArgs = @{
  packageName    = $packageName
  url            = $url
  checksum       = $checksum
  checksumType   = $checksumType
  unzipLocation  = $env:TEMP
}

Install-ChocolateyZipPackage @packageArgs

# Create installation directory
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir
}

# Copy files to installation directory
$tempExtractPath = Join-Path $env:TEMP $packageName
Copy-Item -Recurse -Force "$tempExtractPath\*" $installDir

# Add to PATH if needed (for cmake to find the package)
$cmakePath = Join-Path $installDir "share\cmake"
Install-ChocolateyEnvironmentVariable -VariableName "CMAKE_PREFIX_PATH" -VariableValue $installDir -VariableType "Machine"

Write-Host "abcmake has been installed to $installDir" -ForegroundColor Green
Write-Host "You can now use 'find_package(abcmake REQUIRED)' in your CMakeLists.txt files." -ForegroundColor Green