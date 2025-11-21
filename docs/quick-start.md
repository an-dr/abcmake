# Quick Start Guide

Get up and running with abcmake in minutes. This guide walks you through creating your first abcmake project from scratch.

## Prerequisites

- CMake 3.15 or higher
- C or C++ compiler (GCC, Clang, MSVC, etc.)
- Basic familiarity with CMake

## 5-Minute Setup

### Step 1: Create Project Structure

```bash
mkdir my_project
cd my_project
mkdir src components
```

### Step 2: Download abcmake

Download `ab.cmake` from [releases](https://github.com/an-dr/abcmake/releases) and place it in your project root.

Or use curl/wget:

```bash
# Using curl
curl -L -o ab.cmake https://github.com/an-dr/abcmake/releases/latest/download/ab.cmake

# Using wget
wget -O ab.cmake https://github.com/an-dr/abcmake/releases/latest/download/ab.cmake
```

### Step 3: Create Main CMakeLists.txt

Create `CMakeLists.txt` in the project root:

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp)

include(ab.cmake)

add_main_component(${PROJECT_NAME})
```

### Step 4: Write Your Main Source

Create `src/main.cpp`:

```cpp
#include <iostream>

int main() {
    std::cout << "Hello from abcmake!" << std::endl;
    return 0;
}
```

### Step 5: Build and Run

```bash
cmake -B build
cmake --build build
./build/MyApp  # or .\build\Debug\MyApp.exe on Windows
```

Expected output:
```
Hello from abcmake!
```

Congratulations! You've created your first abcmake project.

## Adding Your First Component

Let's add a reusable library component.

### Step 1: Create Component Structure

```bash
mkdir -p components/greeter/src
mkdir -p components/greeter/include/greeter
```

### Step 2: Create Component CMakeLists.txt

Create `components/greeter/CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.15)
project(greeter)

find_package(abcmake REQUIRED)
# or: include(../../ab.cmake)

add_component(${PROJECT_NAME})
```

### Step 3: Create Component Header

Create `components/greeter/include/greeter/greeter.hpp`:

```cpp
#pragma once
#include <string>

class Greeter {
public:
    explicit Greeter(const std::string& name);
    std::string greet() const;

private:
    std::string name_;
};
```

### Step 4: Create Component Implementation

Create `components/greeter/src/greeter.cpp`:

```cpp
#include "greeter/greeter.hpp"

Greeter::Greeter(const std::string& name) : name_(name) {}

std::string Greeter::greet() const {
    return "Hello, " + name_ + "!";
}
```

### Step 5: Use Component in Main

Update `src/main.cpp`:

```cpp
#include <iostream>
#include "greeter/greeter.hpp"

int main() {
    Greeter greeter("World");
    std::cout << greeter.greet() << std::endl;
    return 0;
}
```

### Step 6: Rebuild

```bash
cmake -B build
cmake --build build
./build/MyApp
```

Expected output:
```
Hello, World!
```

That's it! abcmake automatically:
- Discovered the `greeter` component
- Linked it to your main executable
- Set up include paths
- Handled all dependencies

## Project Structure Overview

Your project should now look like this:

```
my_project/
├── CMakeLists.txt              # Main build configuration
├── ab.cmake                     # abcmake single-file distribution
├── src/
│   └── main.cpp                 # Main application source
├── include/                     # (optional) Public headers for main
└── components/
    └── greeter/                 # Your first component
        ├── CMakeLists.txt       # Component build configuration
        ├── include/
        │   └── greeter/
        │       └── greeter.hpp  # Public component header
        └── src/
            └── greeter.cpp      # Component implementation
```

## Understanding What Happened

Let's break down the magic:

### 1. Main Component Discovery

```cmake
add_main_component(${PROJECT_NAME})
```

This single line:
- Created an executable target named `MyApp`
- Automatically globbed sources from `src/`
- Discovered all components under `components/`
- Linked discovered components automatically

### 2. Component Definition

```cmake
add_component(${PROJECT_NAME})
```

This:
- Created a library target named `greeter`
- Globbed sources from `src/`
- Exposed headers from `include/`
- Made the component linkable by name

### 3. Automatic Linking

abcmake automatically:
- Found the `greeter` component in `components/greeter/`
- Added `components/greeter/include/` to include paths
- Linked the greeter library to MyApp
- Created a `greeter::greeter` alias for external projects

## Common Patterns

### Multiple Source Directories

```cmake
add_component(mylib
    SOURCE_DIR src core utils
    INCLUDE_DIR include public_api)
```

### Shared Library

```cmake
add_component(mylib SHARED)
```

### Header-Only Library

```cmake
add_component(mylib INTERFACE)
```

### Manual Component Linking

```cmake
# Link specific components by path
target_link_components(MyApp
    PATH ${CMAKE_CURRENT_LIST_DIR}/components/greeter)
```

## Next Steps

Now that you've created a basic project, explore more advanced features:

### Learn Core Concepts
- [Concepts Guide](concepts.md) - Understand components, registry, and auto-packages

### Explore Examples
- [Examples](examples.md) - Real-world usage patterns and recipes

### Deep Dive into API
- [API Reference](api.md) - Complete function documentation

### Advanced Topics
- Nested components
- Component sets
- Vendored CMake packages
- Component registry
- Custom project layouts

## Common First-Time Issues

### Issue: "No sources found"

**Problem**: abcmake can't find your source files

**Solution**: Ensure sources are in `src/` or specify `SOURCE_DIR`:

```cmake
add_main_component(MyApp SOURCE_DIR source)
```

### Issue: Header not found

**Problem**: `#include "myheader.hpp"` fails

**Solutions**:

1. Check header is in `include/` directory
2. Use component-namespaced path: `#include "greeter/greeter.hpp"`
3. Specify custom include dir:
   ```cmake
   add_component(mylib INCLUDE_DIR headers)
   ```

### Issue: Multiple definition errors

**Problem**: Linker complains about multiple definitions

**Solution**: Ensure header-only code uses `INTERFACE`:

```cmake
add_component(header_only INTERFACE)
```

### Issue: Component not auto-discovered

**Problem**: Component in `components/` not linked automatically

**Solutions**:

1. Ensure component has its own `CMakeLists.txt` with `add_component()`
2. Check component is in a subdirectory of `components/`
3. Verify component CMakeLists.txt is valid

## Tips for Success

1. **Keep components focused** - One logical module per component
2. **Use include namespacing** - `include/componentname/header.hpp`
3. **Start simple** - Add complexity as needed
4. **Check compile_commands.json** - Generated automatically for IDE support
5. **Use consistent naming** - Match component directory name with target name

## Quick Reference Card

```cmake
# Main executable/library
add_main_component(name [SOURCE_DIR ...] [INCLUDE_DIR ...])

# Library component
add_component(name [SHARED|INTERFACE] [SOURCE_DIR ...] [INCLUDE_DIR ...])

# Manual linking
target_link_components(target PATH path1 path2 NAME comp1 comp2)

# Component registration
register_components(path1 path2 ...)

# Bulk component registration
add_component_set([PATH path] [COMPONENTS ...] [REGISTER_ALL])
```

## Getting Help

- Check [Examples](examples.md) for similar use cases
- Review [API Reference](api.md) for function details
- Search [GitHub Issues](https://github.com/an-dr/abcmake/issues)
- Read [Concepts Guide](concepts.md) for deeper understanding

Happy building with abcmake!
