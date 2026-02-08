<div align="center">

![logo](docs/README/header.drawio.svg)

**Simple, component‑first CMake helper for small & medium C/C++ projects**

[![GitHub Release](https://img.shields.io/github/v/release/an-dr/abcmake?label=latest%20release)](https://github.com/an-dr/abcmake/releases)
[![Build Test](https://github.com/an-dr/abcmake/actions/workflows/test.yml/badge.svg)](https://github.com/an-dr/abcmake/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CMake 3.15+](https://img.shields.io/badge/CMake-3.15+-064F8C?logo=cmake)](https://cmake.org/)

[Quick Start](docs/quick-start.md) •
[Documentation](#documentation) •
[Examples](docs/examples.md) •
[API Reference](docs/api.md)

</div>

---

## Overview

**abcmake** (Andrei's Build CMake subsystem) lets you structure codebases as independent *components* with minimal boilerplate. Drop folders under `components/`, call one function, and get automatic target creation, include paths, and linking.

### Why abcmake?

<table>
<tr>
<td width="50%">

#### Traditional CMake

```cmake
file(GLOB_RECURSE SOURCES "src/*.cpp")
add_library(mylib ${SOURCES})
target_include_directories(mylib PUBLIC include)

add_subdirectory(components/comp_a)
target_link_libraries(mylib PUBLIC comp_a)

add_subdirectory(components/comp_b)
target_link_libraries(mylib PUBLIC comp_b)

# Repeat for every component...
```

</td>
<td width="50%">

#### With abcmake

```cmake
include(ab.cmake)

add_component(mylib)

# Done! All components auto-discovered
# and linked, includes configured
```

</td>
</tr>
</table>

### Key Benefits

| Problem | abcmake Solution |
|---------|-----------------|
| 🔁 Repeating `add_library` + globbing everywhere | Single `add_component()` with auto-discovery |
| 📦 Hard to reuse internal modules | Component folders become portable units |
| 🔗 Tedious dependency wiring | Automatic linking + optional registry |
| 📚 Vendored CMake packages cumbersome | Auto-detect & link `*Config.cmake` packages |
| 📈 Monolithic CMakeLists.txt growth | Natural split by component directory |

## Features

- ✨ **Zero dependencies** - Pure CMake 3.15+, no Python or external tools
- 🎯 **Convention over configuration** - Sensible defaults, override when needed
- 🔍 **Automatic discovery** - Recursive component detection and linking
- 📝 **Component registry** - Link by name instead of path
- 🧩 **Component sets** - Bulk registration without building
- 🔌 **Package auto-detection** - Vendored `*Config.cmake` packages just work
- 🏷️ **Automatic aliases** - `<name>::<name>` for parent project compatibility
- 🛠️ **IDE support** - Generates `compile_commands.json` by default
- 📦 **Single-file distribution** - Just download `ab.cmake`

## Quick Start

### 1. Install

#### Option A: Project-Scoped (Recommended)

Download [`ab.cmake`](https://github.com/an-dr/abcmake/releases/latest/download/ab.cmake) to your project root.

#### Option B: Package Manager (vcpkg, CPM)

```bash
vcpkg install abcmake  # vcpkg
```

```cmake
CPMAddPackage("gh:an-dr/abcmake@6.4.0" DOWNLOAD_ONLY YES)  # CPM
include(${abcmake_SOURCE_DIR}/src/ab.cmake)
```

#### Option C: User/System-Wide

```bash
git clone https://github.com/an-dr/abcmake.git
cd abcmake
cmake -B build
cmake --install build --prefix ~/.local
```

📖 [Detailed Installation Guide](docs/installation.md)

### 2. Create Your Project

**CMakeLists.txt:**

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp)

include(ab.cmake)

add_main_component(${PROJECT_NAME})
```

**src/main.cpp:**

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, abcmake!" << std::endl;
    return 0;
}
```

**Build:**

```bash
cmake -B build
cmake --build build
./build/MyApp
```

### 3. Add a Component

**components/greeter/CMakeLists.txt:**

```cmake
cmake_minimum_required(VERSION 3.15)
project(greeter)

include(../../ab.cmake)

add_component(${PROJECT_NAME})
```

**components/greeter/include/greeter/greeter.hpp:**

```cpp
#pragma once
#include <string>

std::string greet(const std::string& name);
```

**components/greeter/src/greeter.cpp:**

```cpp
#include "greeter/greeter.hpp"

std::string greet(const std::string& name) {
    return "Hello, " + name + "!";
}
```

That's it! The component is automatically discovered, built, and linked.

📖 [Full Quick Start Guide](docs/quick-start.md)

## Documentation

### Getting Started

- 🚀 [Quick Start Guide](docs/quick-start.md) - Get up and running in 5 minutes
- 📦 [Installation Guide](docs/installation.md) - Detailed installation options
- 💡 [Core Concepts](docs/concepts.md) - Understand the component model

### References

- 📚 [API Reference](docs/api.md) - Complete function documentation
- 🔧 [Examples](docs/examples.md) - Real-world usage patterns
- 📝 [Changelog](CHANGELOG.md) - Version history and changes

### Contributing

- 🤝 [Contributing Guide](CONTRIBUTING.md) - How to contribute
- 🐛 [Issue Tracker](https://github.com/an-dr/abcmake/issues) - Report bugs or request features

## Project Structure

```text
my_project/
├── CMakeLists.txt              # include(ab.cmake) + add_main_component()
├── ab.cmake                     # Single-file abcmake distribution
├── src/                         # Main application sources
│   └── main.cpp
├── include/                     # (Optional) Public headers
│   └── myapp/
│       └── config.hpp
└── components/                  # Auto-discovered components
    ├── component_a/
    │   ├── CMakeLists.txt       # add_component(component_a)
    │   ├── include/component_a/
    │   │   └── api.hpp
    │   └── src/
    │       └── impl.cpp
    └── component_b/
        ├── CMakeLists.txt
        └── ...
```

## API at a Glance

```cmake
# Create main executable with auto-discovery
add_main_component(<name> [SOURCE_DIR ...] [INCLUDE_DIR ...])

# Create library component (static by default)
add_component(<name> [SHARED|INTERFACE] [SOURCE_DIR ...] [INCLUDE_DIR ...])

# Register components for name-based linking
register_components(<path>...)

# Link components by path or name
target_link_components(<target> [PATH <path>...] [NAME <name>...])

# Bulk register components without building
add_component_set([PATH <path>] [COMPONENTS ...] [REGISTER_ALL])
```

📖 [Complete API Documentation](docs/api.md)

## Examples

### Multiple Source Directories

```cmake
add_component(core
    SOURCE_DIR src generated
    INCLUDE_DIR include public_api)
```

### Component Registry

```cmake
# Register once
register_components(
    ${CMAKE_CURRENT_LIST_DIR}/components/logger
    ${CMAKE_CURRENT_LIST_DIR}/components/config)

# Link by name anywhere
target_link_components(app NAME logger config)
```

### Shared Library

```cmake
add_component(myplugin SHARED)
```

### Header-Only Library

```cmake
add_component(templates INTERFACE)
```

📖 [More Examples](docs/examples.md)

## Requirements

- **CMake** 3.15 or higher
- **C/C++ compiler** (GCC, Clang, MSVC, etc.)
- **Platforms**: Linux, macOS, Windows

## FAQ

<details>
<summary><b>Can I use abcmake with existing CMake projects?</b></summary>

Yes! abcmake components create standard CMake targets with `<name>::<name>` aliases. Parent projects can use them with `add_subdirectory()` whether or not they use abcmake.
</details>

<details>
<summary><b>Does abcmake support header-only libraries?</b></summary>

Absolutely! Use `add_component(<name> INTERFACE)` for header-only components.
</details>

<details>
<summary><b>How do I integrate third-party libraries?</b></summary>

Drop vendored libraries with `*Config.cmake` into `components/` - they're auto-detected and linked. Or use standard CMake `find_package()` and `target_link_libraries()`.
</details>

<details>
<summary><b>Can components have sub-components?</b></summary>

Yes! Components can have their own `components/` directory with nested components. Discovery is recursive.
</details>

<details>
<summary><b>Is abcmake suitable for large projects?</b></summary>

abcmake is optimized for small to medium projects. Very large monorepos may prefer native CMake patterns for fine-grained control.
</details>

## Limitations

- 📋 One logical component per `CMakeLists.txt` (keeps components focused)
- 🎯 Best suited for small/medium projects (large monorepos may need more control)
- 🔧 Convention-based (less flexibility than raw CMake for complex scenarios)

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for:

- 🐛 Reporting bugs
- 💡 Suggesting features
- 🔧 Development setup
- ✅ Running tests
- 📝 Documentation improvements

**Testing:**

```bash
cd tests
python -m unittest discover -v
```

## License

MIT License © [Andrei Gramakov](https://github.com/an-dr)

See [LICENSE](LICENSE) for details.

---

<div align="center">

**[⬆ Back to Top](#overview)**

Made with ❤️ by the abcmake community

</div>
