# abcmake Tests

This directory contains automated tests for the abcmake build system.

## Test Structure

### Build Tests (`test_project_build.py`)
Tests that verify abcmake can build various project configurations:
- `test_interdep` - Components with interdependencies
- `test_default_project` - Standard project layout
- `test_many_folders` - Projects with many source folders
- `test_project_custom` - Custom project configurations
- `test_register` - Component registration system
- `test_compile_commands` - compile_commands.json generation
- `test_cmake_package` - Auto-detection of CMake packages

### Installation Tests (`test_find_package_install.py`)
Tests that verify abcmake can be installed system-wide and found via `find_package()`:
- `test_install_and_find_package` - Complete install workflow
- `test_find_package_with_custom_prefix` - Custom installation prefix

### Standalone Test (`test_find_package.cmake`)
A CMake script that verifies find_package() functionality without requiring Python.

**Usage:**
```bash
# Run from project root after installation
cmake -P tests/test_find_package.cmake

# Or with custom install prefix
cmake -DINSTALL_PREFIX=/path/to/install -P tests/test_find_package.cmake
```

## Running Tests

### Run All Tests
```bash
cd tests
python -m unittest discover -v
```

### Run Specific Test Suite
```bash
cd tests
python -m unittest test_project_build -v
python -m unittest test_find_package_install -v
```

### Run Individual Test
```bash
cd tests
python -m unittest test_find_package_install.TestFindPackage.test_install_and_find_package -v
```

### Run CMake Script Test
```bash
# First, install abcmake to test location
cmake -B build -G Ninja
cmake --install build --prefix ./test_install

# Then run the test
cmake -P tests/test_find_package.cmake
```

## Test Requirements

- Python 3.x
- CMake >= 3.5
- Ninja build system (or another CMake-supported generator)
- C/C++ compiler

## Test Directories

Each test directory under `tests/` contains:
- `CMakeLists.txt` - Project configuration using abcmake
- `components/` - Component subdirectories
- Various source and header files

These are minimal examples that exercise different abcmake features.

## Adding New Tests

1. **For build tests**: Add a new test method to `test_project_build.py`
2. **For installation tests**: Add to `test_find_package_install.py`
3. **For standalone CMake tests**: Create a new `.cmake` script

Example build test:
```python
def test_my_feature(self):
    self.build_cmake("test_my_feature")
```

## Continuous Integration

Tests are automatically run on GitHub Actions. See `.github/workflows/test.yml` for the CI configuration.

## Troubleshooting

### Tests fail with "CMake not found"
Ensure CMake is installed and in your PATH:
```bash
cmake --version
```

### Tests fail with compiler errors
The test system requires a working C/C++ compiler. Install:
- **Linux**: `gcc` and `g++`
- **macOS**: Xcode Command Line Tools
- **Windows**: Visual Studio, MinGW, or MSVC

### Installation tests fail
Make sure you have write permissions to the test installation directory, or the tests will create a `test_install` directory in the project root.
