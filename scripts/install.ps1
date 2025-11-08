# *************************************************************************
#
# Copyright (c) 2024 Andrei Gramakov. All rights reserved.
#
# abcmake Installation Script for Windows PowerShell
# This script automatically downloads and installs the latest abcmake release.
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.ps1 | iex
#   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.ps1" -UseBasicParsing | Invoke-Expression
#
# Parameters:
#   -User          Install to user profile instead of system-wide
#   -Prefix        Install to custom prefix path
#   -Version       Install specific version (e.g., "v6.2.0")
#   -Help          Show help message
#
# *************************************************************************

[CmdletBinding()]
param(
    [string]$Prefix = "",
    [switch]$User = $false,
    [string]$Version = "latest",
    [switch]$Help = $false
)

# Configuration
$RepoOwner = "an-dr"
$RepoName = "abcmake"
$TempDir = ""

# Colors for output (PowerShell 5.1+ supports ANSI colors with proper setup)
$ColorReset = "`e[0m"
$ColorRed = "`e[31m"
$ColorGreen = "`e[32m"
$ColorYellow = "`e[33m"
$ColorBlue = "`e[34m"

# Check if we can use colors
$UseColors = $true
if ($PSVersionTable.PSVersion.Major -lt 7) {
    # For PowerShell 5.1, disable colors as they may not work reliably
    $UseColors = $false
    $ColorReset = ""
    $ColorRed = ""
    $ColorGreen = ""
    $ColorYellow = ""
    $ColorBlue = ""
}

# Logging functions
function Write-LogInfo {
    param($Message)
    if ($UseColors) {
        Write-Host "$ColorBlue[INFO]$ColorReset $Message"
    } else {
        Write-Host "[INFO] $Message"
    }
}

function Write-LogSuccess {
    param($Message)
    if ($UseColors) {
        Write-Host "$ColorGreen[SUCCESS]$ColorReset $Message"
    } else {
        Write-Host "[SUCCESS] $Message"
    }
}

function Write-LogWarning {
    param($Message)
    if ($UseColors) {
        Write-Host "$ColorYellow[WARNING]$ColorReset $Message"
    } else {
        Write-Warning $Message
    }
}

function Write-LogError {
    param($Message)
    if ($UseColors) {
        Write-Host "$ColorRed[ERROR]$ColorReset $Message"
    } else {
        Write-Error $Message
    }
}

# Show help
function Show-Help {
    @"
abcmake Installation Script for Windows

USAGE:
    iwr -useb https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.ps1 | iex
    
    PowerShell.exe -ExecutionPolicy Bypass -File install.ps1 [OPTIONS]

OPTIONS:
    -User           Install to user profile instead of system-wide (no admin required)
    -Prefix PATH    Install to custom prefix directory
    -Version TAG    Install specific version (e.g., "v6.2.0", default: "latest")
    -Help           Show this help message

EXAMPLES:
    # System-wide installation (requires admin privileges)
    .\install.ps1

    # User installation (no admin required)
    .\install.ps1 -User

    # Custom prefix
    .\install.ps1 -Prefix "C:\Tools\abcmake"

    # Specific version
    .\install.ps1 -Version "v6.2.0" -User

REQUIREMENTS:
    - PowerShell 5.1 or later
    - .NET Framework or .NET Core
    - cmake (for using abcmake)

"@
}

# Cleanup function
function Cleanup {
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Check if running as administrator
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Get latest release version
function Get-LatestVersion {
    try {
        $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        return $response.tag_name
    }
    catch {
        Write-LogError "Failed to get latest version: $($_.Exception.Message)"
        throw
    }
}

# Download file with progress
function Get-FileFromUrl {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    try {
        Write-LogInfo "Downloading from $Url"
        
        # Use Invoke-WebRequest with progress for better user experience
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        
        if (-not (Test-Path $OutputPath)) {
            throw "Download failed - file not found at $OutputPath"
        }
        
        Write-LogInfo "Download completed: $(Get-Item $OutputPath | ForEach-Object { '{0:N2}' -f ($_.Length / 1MB) }) MB"
    }
    catch {
        Write-LogError "Download failed: $($_.Exception.Message)"
        throw
    }
}

# Determine installation prefix
function Get-InstallPrefix {
    if ($Prefix) {
        return $Prefix
    }
    elseif ($User) {
        return Join-Path $env:USERPROFILE "abcmake"
    }
    else {
        return "C:\Program Files\abcmake"
    }
}

# Extract tar.gz file on Windows
function Expand-TarGzArchive {
    param(
        [string]$ArchivePath,
        [string]$DestinationPath
    )
    
    try {
        Write-LogInfo "Extracting archive to $DestinationPath"
        
        # For PowerShell 5.1 and later, we can use tar if available, or PowerShell's Expand-Archive
        if (Get-Command tar -ErrorAction SilentlyContinue) {
            # Use system tar if available (Windows 10 build 17063+)
            & tar -xzf $ArchivePath -C $DestinationPath
        }
        else {
            # Fallback: First extract .gz to .tar, then extract .tar
            $tarPath = $ArchivePath -replace '\.gz$', ''
            
            # Extract .gz using .NET
            $gzipStream = New-Object System.IO.Compression.GzipStream([System.IO.File]::OpenRead($ArchivePath), [System.IO.Compression.CompressionMode]::Decompress)
            $output = [System.IO.File]::Create($tarPath)
            $gzipStream.CopyTo($output)
            $output.Close()
            $gzipStream.Close()
            
            # Now we need to extract the tar file
            # This is complex in pure PowerShell, so we'll recommend using a tool
            Write-LogWarning "Automatic extraction requires 'tar' command. Please extract manually:"
            Write-LogWarning "1. Extract $tarPath to $DestinationPath"
            Write-LogWarning "2. Run this script again to complete installation"
            throw "Manual extraction required"
        }
        
        Write-LogSuccess "Archive extracted successfully"
    }
    catch {
        Write-LogError "Extraction failed: $($_.Exception.Message)"
        throw
    }
}

# Install abcmake
function Install-Abcmake {
    param(
        [string]$InstallPrefix,
        [string]$InstallVersion,
        [bool]$NeedsAdmin,
        [string]$TempDirectory
    )
    
    try {
        Write-LogInfo "Installing abcmake $InstallVersion to $InstallPrefix"
        
        # Download installation package
        $packageUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/$InstallVersion/abcmake-$InstallVersion-install.tar.gz"
        $packageFile = Join-Path $TempDirectory "abcmake-install.tar.gz"
        
        Get-FileFromUrl -Url $packageUrl -OutputPath $packageFile
        
        # Create installation directory
        if (-not (Test-Path $InstallPrefix)) {
            New-Item -Path $InstallPrefix -ItemType Directory -Force | Out-Null
            Write-LogInfo "Created directory: $InstallPrefix"
        }
        
        # Extract package
        Expand-TarGzArchive -ArchivePath $packageFile -DestinationPath $InstallPrefix
        
        # Verify installation
        $cmakeDir = Join-Path $InstallPrefix "share\cmake\abcmake"
        $abCmakeFile = Join-Path $cmakeDir "ab.cmake"
        
        if (Test-Path $abCmakeFile) {
            Write-LogSuccess "abcmake installed successfully!"
            Write-LogInfo "Installation directory: $cmakeDir"
            return $true
        }
        else {
            Write-LogError "Installation verification failed - ab.cmake not found"
            return $false
        }
    }
    catch {
        Write-LogError "Installation failed: $($_.Exception.Message)"
        return $false
    }
}

# Show usage instructions
function Show-UsageInstructions {
    param([string]$InstallPrefix)
    
    Write-Host ""
    Write-Host "=== abcmake Installation Complete ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "To use abcmake in your CMake projects, add this to your CMakeLists.txt:"
    Write-Host ""
    Write-Host "    find_package(abcmake REQUIRED)" -ForegroundColor Cyan
    Write-Host "    # All abcmake functions are now available" -ForegroundColor Gray
    Write-Host "    add_main_component(`${PROJECT_NAME})" -ForegroundColor Cyan
    Write-Host ""
    
    $isStandardPath = $InstallPrefix -eq "C:\Program Files\abcmake" -or $InstallPrefix -eq "C:\cmake"
    
    if (-not $isStandardPath) {
        Write-Host "Since you installed to a custom location, you may need to help CMake find it:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Option 1: Set CMAKE_PREFIX_PATH when configuring:" -ForegroundColor Yellow
        Write-Host "    cmake -B build -DCMAKE_PREFIX_PATH=`"$InstallPrefix`"" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Option 2: Set it in your CMakeLists.txt before find_package():" -ForegroundColor Yellow
        Write-Host "    list(APPEND CMAKE_PREFIX_PATH `"$InstallPrefix`")" -ForegroundColor Cyan
        Write-Host ""
    }
    
    if ($User) {
        Write-Host "For user installations, you might want to add this to your environment:" -ForegroundColor Yellow
        Write-Host "    setx CMAKE_PREFIX_PATH `"$InstallPrefix;%CMAKE_PREFIX_PATH%`"" -ForegroundColor Cyan
        Write-Host ""
    }
    
    Write-Host "Documentation: https://github.com/$RepoOwner/$RepoName"
    Write-Host "Examples: https://github.com/$RepoOwner/$RepoName/tree/main/examples"
}

# Main function
function Main {
    # Show help if requested
    if ($Help) {
        Show-Help
        return
    }
    
    try {
        # Set up cleanup
        Register-EngineEvent PowerShell.Exiting -Action { Cleanup } | Out-Null
        
        # Create temporary directory
        $script:TempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
        Write-LogInfo "Created temporary directory: $TempDir"
        
        # Determine version to install
        if ($Version -eq "latest") {
            Write-LogInfo "Getting latest version..."
            $Version = Get-LatestVersion
            Write-LogInfo "Latest version: $Version"
        }
        
        # Determine installation prefix
        $InstallPrefix = Get-InstallPrefix
        Write-LogInfo "Installation prefix: $InstallPrefix"
        
        # Check if admin rights are needed
        $needsAdmin = $false
        if (-not $User -and -not $Prefix) {
            $needsAdmin = $true
            if (-not (Test-IsAdmin)) {
                Write-LogError "System-wide installation requires administrator privileges."
                Write-LogInfo "Either run PowerShell as Administrator, or use -User for user installation."
                return
            }
        }
        
        # Check prerequisites
        $cmakeAvailable = Get-Command cmake -ErrorAction SilentlyContinue
        if (-not $cmakeAvailable) {
            Write-LogWarning "CMake is not installed or not in PATH. You'll need it to use abcmake."
            Write-LogInfo "Download CMake from: https://cmake.org/download/"
        }
        
        # Install abcmake
        $success = Install-Abcmake -InstallPrefix $InstallPrefix -InstallVersion $Version -NeedsAdmin $needsAdmin -TempDirectory $TempDir
        
        if ($success) {
            Show-UsageInstructions -InstallPrefix $InstallPrefix
        }
        else {
            Write-LogError "Installation failed"
            exit 1
        }
    }
    catch {
        Write-LogError "Installation failed: $($_.Exception.Message)"
        exit 1
    }
    finally {
        Cleanup
    }
}

# Run main function if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
