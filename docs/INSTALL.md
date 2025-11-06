# Installation Guide

## System-wide Installation

Installing abcmake system-wide allows you to use `find_package(abcmake)` in any CMake project without copying files.

### Installation Steps

1. **Clone the repository** (or download a release):
   ```bash
   git clone https://github.com/an-dr/abcmake.git
   cd abcmake
   ```

2. **Configure the build**:
   ```bash
   cmake -B build
   ```

3. **Install** (may require sudo/administrator privileges):

   **Linux/macOS**:
   ```bash
   sudo cmake --install build --prefix /usr/local
   ```

   **Windows**:
   ```bash
   cmake --install build --prefix "C:/Program Files/abcmake"
   ```

   Or install to a user directory (no admin required):
   ```bash
   cmake --install build --prefix ~/.local
   ```

### Custom Installation Prefix

You can install to any location:

```bash
cmake --install build --prefix /path/to/installation
```

Then when using abcmake in your projects, set `CMAKE_PREFIX_PATH`:

```bash
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/installation
```

Or set it in your CMakeLists.txt before `find_package()`:

```cmake
list(APPEND CMAKE_PREFIX_PATH "/path/to/installation")
find_package(abcmake REQUIRED)
```

## Using Installed abcmake

After installation, use abcmake in your projects like this:

### CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.5)
project(MyProject)

# Find the installed abcmake package
find_package(abcmake REQUIRED)

# All abcmake functions are now available
add_main_component(${PROJECT_NAME})
```

### Project Structure

```text
my_project/
    CMakeLists.txt
    src/
        main.cpp
    include/
        my_project/
            header.h
    components/
        mylib/
            CMakeLists.txt
            src/
                lib.cpp
            include/
                mylib/
                    lib.h
```

### Component CMakeLists.txt

Components can also use the installed abcmake:

```cmake
cmake_minimum_required(VERSION 3.5)
project(mylib)

# If abcmake was found by the parent, it's already available
# Otherwise, find it again
if(NOT abcmake_FOUND)
    find_package(abcmake REQUIRED)
endif()

add_component(${PROJECT_NAME})
```

## Uninstallation

CMake doesn't provide a built-in uninstall mechanism, but you can manually remove the files:

**Linux/macOS** (if installed to `/usr/local`):
```bash
sudo rm -rf /usr/local/share/cmake/abcmake
```

**Windows** (if installed to `C:/Program Files/abcmake`):
```cmd
rmdir /s "C:\Program Files\abcmake\share\cmake\abcmake"
```

## Verification

To verify the installation, check that CMake can find abcmake:

```bash
cmake --find-package -DNAME=abcmake -DCOMPILER_ID=GNU -DLANGUAGE=C -DMODE=EXIST
```

Or create a minimal test project and run:

```bash
cd test_project
cmake -B build
```

You should see: `Found abcmake: X.X.X (/path/to/installation)`

## Troubleshooting

### CMake can't find abcmake

1. **Check CMAKE_PREFIX_PATH**: Make sure the installation prefix is in `CMAKE_PREFIX_PATH`
2. **Check installation directory**: Verify files exist at `<prefix>/share/cmake/abcmake/`
3. **Use absolute path**: Temporarily use `find_package(abcmake REQUIRED PATHS /path/to/install/share/cmake/abcmake)`

### Permission denied during installation

- Use `sudo` on Linux/macOS
- Run terminal as Administrator on Windows
- Or install to a user directory (e.g., `~/.local` or `%USERPROFILE%\abcmake`)

### Environment-specific issues

If you have multiple CMake versions or custom setups, ensure:
- CMake version >= 3.5
- The `CMAKE_MODULE_PATH` doesn't override standard package search paths
