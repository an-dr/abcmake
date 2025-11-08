# Package Manager Integration

This directory contains configuration files for various package managers to distribute abcmake.

## Status

### ✅ Ready for Use
- **Manual Installation Scripts**: `install.sh` (Unix/Linux/macOS) and `install.ps1` (Windows)
- **CMake Package**: Full CMake package support with `find_package(abcmake)`

### 🚧 In Development
- **Homebrew**: Formula ready, needs testing and submission to homebrew-core or custom tap
- **Chocolatey**: Package spec ready, needs testing and submission to Chocolatey Community Repository

### 📋 Planned
- **APT/DEB packages**: For Ubuntu/Debian distributions
- **RPM packages**: For RedHat/Fedora/CentOS distributions
- **AUR package**: For Arch Linux
- **Vcpkg**: For C++ package management
- **Conan**: Alternative C++ package manager

## Usage by Package Manager

### Homebrew (macOS/Linux)
*When available:*
```bash
brew install abcmake
```

### Chocolatey (Windows)
*When available:*
```powershell
choco install abcmake
```

### APT (Ubuntu/Debian)
*Planned:*
```bash
sudo apt install abcmake
```

### Current Recommended Installation

Until package managers are available, use the installation scripts:

**Unix/Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.sh | bash
```

**Windows:**
```powershell
iwr -useb https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.ps1 | iex
```

## Contributing to Package Distribution

If you'd like to help package abcmake for a specific package manager:

1. Test the existing package specifications in this directory
2. Submit packages to the respective repositories (with maintainer approval)
3. Update this README with the status
4. Submit a PR with any improvements to the package specs

## Package Maintainer Notes

- All packages should install abcmake to standard system locations
- CMake should be able to find abcmake via `find_package(abcmake)` after installation
- Version numbers should match the GitHub release tags
- Package descriptions should be consistent across package managers