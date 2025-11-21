# Installation Guide

This guide covers different methods to install and use abcmake in your projects.

## Table of Contents

- [Quick Installation](#quick-installation)
- [Project-Scoped Installation](#project-scoped-installation)
- [User-Scoped Installation](#user-scoped-installation)
- [System-Wide Installation](#system-wide-installation)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Quick Installation

For most users, the **project-scoped** approach is the simplest and most portable option.

## Project-Scoped Installation

This method bundles abcmake directly with your project - ideal for portability and version control.

### Step 1: Download the Single-File Distribution

Download `ab.cmake` from the [latest release](https://github.com/an-dr/abcmake/releases) and place it in your project root (or a subdirectory like `cmake/`).

### Step 2: Include in Your CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject)

# Include abcmake
include(ab.cmake)
# or: include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ab.cmake)

# Use abcmake
add_main_component(${PROJECT_NAME})
```

### Advantages

- **Portable**: Works anywhere without system installation
- **Version control**: Track abcmake version with your project
- **No dependencies**: Self-contained single file
- **Team-friendly**: Everyone uses the same version

### Disadvantages

- Need to update `ab.cmake` manually for new versions
- File duplicated across multiple projects

## User-Scoped Installation

Install abcmake for your user account - useful when working on multiple projects.

### Linux and macOS

```bash
# Clone the repository
git clone https://github.com/an-dr/abcmake.git
cd abcmake

# Build and install to user directory
cmake -B build
cmake --install build --prefix ~/.local
```

Add to your CMakeLists.txt:

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject)

# CMake automatically searches ~/.local
find_package(abcmake REQUIRED)

add_main_component(${PROJECT_NAME})
```

### Windows

```powershell
# Clone the repository
git clone https://github.com/an-dr/abcmake.git
cd abcmake

# Build and install to user AppData
cmake -B build
cmake --install build --prefix "$env:LOCALAPPDATA\CMake"
```

Add to your CMakeLists.txt:

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject)

# Help CMake find the package
list(APPEND CMAKE_PREFIX_PATH "$ENV{LOCALAPPDATA}/CMake")
find_package(abcmake REQUIRED)

add_main_component(${PROJECT_NAME})
```

### Advantages

- Available across all your projects
- Easy to update (re-run install)
- No admin/root privileges needed

### Disadvantages

- Not included in version control
- Team members need separate installation
- Path configuration may be needed

## System-Wide Installation

Install abcmake for all users on the system - best for shared development machines.

### Linux

```bash
git clone https://github.com/an-dr/abcmake.git
cd abcmake

cmake -B build
sudo cmake --install build --prefix /usr/local
```

### macOS

```bash
git clone https://github.com/an-dr/abcmake.git
cd abcmake

cmake -B build
sudo cmake --install build --prefix /usr/local
```

### Windows (Administrator)

```powershell
# Run PowerShell as Administrator
git clone https://github.com/an-dr/abcmake.git
cd abcmake

cmake -B build
cmake --install build --prefix "C:\Program Files\CMake"
```

Use in your project:

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject)

find_package(abcmake REQUIRED)
add_main_component(${PROJECT_NAME})
```

### Advantages

- Available to all users
- No per-project or per-user setup needed
- Clean CMakeLists.txt

### Disadvantages

- Requires administrator privileges
- May conflict with other versions
- Not portable across machines

## Verification

After installation, verify abcmake is working:

### For find_package() Installations

Create a minimal test project:

```cmake
# test/CMakeLists.txt
cmake_minimum_required(VERSION 3.15)
project(AbcmakeTest)

find_package(abcmake REQUIRED)

message(STATUS "abcmake found successfully!")
message(STATUS "abcmake version: ${abcmake_VERSION}")
```

Run:

```bash
cd test
cmake -B build
```

Expected output:
```
-- abcmake found successfully!
-- abcmake version: X.Y.Z
```

### For include() Installations

Create a minimal test:

```cmake
# test/CMakeLists.txt
cmake_minimum_required(VERSION 3.15)
project(AbcmakeTest)

include(ab.cmake)

message(STATUS "abcmake loaded successfully!")

# Create a dummy component
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/test.cpp" "int main() { return 0; }")
add_main_component(test SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR})
```

## Troubleshooting

### CMake Cannot Find abcmake Package

**Problem**: `find_package(abcmake REQUIRED)` fails with "Could not find abcmake"

**Solutions**:

1. **Check installation path**:
   ```bash
   # Linux/macOS
   ls ~/.local/lib/cmake/abcmake/
   ls /usr/local/lib/cmake/abcmake/

   # Windows
   dir "%LOCALAPPDATA%\CMake\lib\cmake\abcmake\"
   dir "C:\Program Files\CMake\lib\cmake\abcmake\"
   ```

2. **Add to CMAKE_PREFIX_PATH**:
   ```cmake
   list(APPEND CMAKE_PREFIX_PATH "/path/to/install/prefix")
   find_package(abcmake REQUIRED)
   ```

3. **Use environment variable**:
   ```bash
   export CMAKE_PREFIX_PATH="/path/to/install/prefix:$CMAKE_PREFIX_PATH"
   cmake -B build
   ```

### Permission Denied During Installation

**Problem**: Installation fails with permission errors

**Solutions**:

1. Use user-scoped installation instead of system-wide
2. Use `sudo` on Linux/macOS
3. Run PowerShell as Administrator on Windows
4. Check directory permissions

### Wrong abcmake Version Loaded

**Problem**: CMake loads a different version than expected

**Solutions**:

1. **Remove old installations**:
   ```bash
   # Find all installations
   cmake --find-package -DNAME=abcmake -DCOMPILER_ID=GNU -DLANGUAGE=C -DMODE=EXIST
   ```

2. **Specify version requirement**:
   ```cmake
   find_package(abcmake 1.2.3 EXACT REQUIRED)
   ```

3. **Clear CMake cache**:
   ```bash
   rm -rf build/
   cmake -B build
   ```

### include(ab.cmake) File Not Found

**Problem**: `include(ab.cmake)` fails to find the file

**Solutions**:

1. **Use absolute path**:
   ```cmake
   include(${CMAKE_CURRENT_SOURCE_DIR}/ab.cmake)
   ```

2. **Use CMAKE_MODULE_PATH**:
   ```cmake
   list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
   include(ab.cmake)  # looks in cmake/ directory
   ```

3. **Verify file exists**:
   ```bash
   ls ab.cmake
   ls cmake/ab.cmake
   ```

## Updating abcmake

### Project-Scoped Updates

Download the new `ab.cmake` from releases and replace the old file:

```bash
# Backup current version
cp ab.cmake ab.cmake.backup

# Download new version (example using curl)
curl -L -o ab.cmake https://github.com/an-dr/abcmake/releases/download/vX.Y.Z/ab.cmake

# Test with your project
cmake -B build

# If successful, commit
git add ab.cmake
git commit -m "Update abcmake to vX.Y.Z"
```

### User/System-Scoped Updates

Re-run the installation:

```bash
cd abcmake
git pull origin main
cmake -B build
cmake --install build --prefix ~/.local  # or your preferred prefix
```

## Uninstallation

### Project-Scoped

Simply delete the `ab.cmake` file and remove the `include()` line from CMakeLists.txt.

### User/System-Scoped

```bash
# From the build directory
cmake --build build --target uninstall

# Or manually remove installation
rm -rf ~/.local/lib/cmake/abcmake
rm -rf /usr/local/lib/cmake/abcmake
```

Windows:
```powershell
Remove-Item -Recurse "$env:LOCALAPPDATA\CMake\lib\cmake\abcmake"
```

## Next Steps

- [Quick Start Guide](quick-start.md) - Get started with your first project
- [API Reference](api.md) - Detailed function documentation
- [Examples](examples.md) - Real-world usage examples
