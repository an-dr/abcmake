# Hello World Example Using find_package()

This example demonstrates using abcmake after it has been installed system-wide.

## Prerequisites

Install abcmake first:

```bash
cd /path/to/abcmake
cmake -B build
sudo cmake --install build --prefix /usr/local  # or your preferred prefix
```

## Building This Example

Once abcmake is installed, you can build this example:

```bash
cd examples/hello_with_find_package
cmake -B build
cmake --build build
./build/HelloWorld  # or .\build\Debug\HelloWorld.exe on Windows
```

## How It Works

The `CMakeLists.txt` uses `find_package(abcmake REQUIRED)` to locate the installed abcmake package. CMake searches standard locations like:

- Linux/macOS: `/usr/local/share/cmake/abcmake/`, `/usr/share/cmake/abcmake/`
- Windows: `C:/Program Files/abcmake/share/cmake/abcmake/`

If abcmake is installed elsewhere, set `CMAKE_PREFIX_PATH`:

```bash
cmake -B build -DCMAKE_PREFIX_PATH=/custom/install/path
```

## Advantages of find_package()

1. **No file copying**: Don't need to copy `ab.cmake` to every project
2. **Version control**: CMake can check version compatibility
3. **Cleaner projects**: No vendored dependencies
4. **Easy updates**: Update abcmake once, all projects benefit
