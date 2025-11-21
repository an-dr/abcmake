# Core Concepts

This guide explains the fundamental concepts and design philosophy behind abcmake.

## Table of Contents

- [Philosophy](#philosophy)
- [Component Model](#component-model)
- [Component Discovery](#component-discovery)
- [The Component Registry](#the-component-registry)
- [Auto Package Detection](#auto-package-detection)
- [Directory Conventions](#directory-conventions)
- [Target Types](#target-types)
- [Linking Model](#linking-model)
- [Component Sets](#component-sets)
- [Best Practices](#best-practices)

## Philosophy

abcmake is built on these core principles:

### 1. Convention Over Configuration

Rather than manually specifying every detail, abcmake uses sensible defaults:

- Sources in `src/` are automatically globbed
- Headers in `include/` are automatically exposed
- Components in `components/` are automatically discovered
- Linking happens automatically when possible

### 2. Component-First Architecture

Everything is a component. This promotes:

- **Modularity** - Clear boundaries between code modules
- **Reusability** - Components can be easily moved between projects
- **Testability** - Components can be tested in isolation
- **Maintainability** - Changes are localized to component boundaries

### 3. Minimal Boilerplate

Traditional CMake requires repetitive patterns. abcmake reduces this:

**Traditional CMake:**
```cmake
file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "include/*.hpp")
add_library(mylib ${SOURCES} ${HEADERS})
target_include_directories(mylib PUBLIC include)
add_subdirectory(components/component_a)
target_link_libraries(mylib PUBLIC component_a)
add_subdirectory(components/component_b)
target_link_libraries(mylib PUBLIC component_b)
# ... repeat for every component
```

**With abcmake:**
```cmake
add_component(mylib)
# Done! All discovery and linking automatic
```

### 4. Zero External Dependencies

abcmake is pure CMake - no Python scripts, no external tools. Just include one file and go.

## Component Model

### What is a Component?

A **component** is a self-contained unit of code with:

- Its own directory
- Its own `CMakeLists.txt`
- Clear public interface (headers)
- Implementation (sources)
- Optional dependencies (other components)

### Component Anatomy

```
component_name/
├── CMakeLists.txt          # Build configuration
├── include/                # Public headers (API)
│   └── component_name/     # Namespaced headers
│       └── api.hpp
├── src/                    # Private implementation
│   ├── impl.cpp
│   └── internal.hpp        # Private headers
└── components/             # Optional sub-components
    └── subcomponent/
```

### Component Types

#### 1. Main Component

The top-level executable or library of your project.

```cmake
add_main_component(MyApp)
```

Properties:
- Typically an executable
- Auto-discovers nested components
- Root of dependency tree

#### 2. Library Component (Static)

Standard library component, linked statically.

```cmake
add_component(mylib)
```

Properties:
- Created as static library by default
- Binary code compiled into consumer
- No runtime dependency

#### 3. Shared Library Component

Component compiled as shared/dynamic library.

```cmake
add_component(mylib SHARED)
```

Properties:
- Created as shared library (.so/.dll/.dylib)
- Loaded at runtime
- Can be updated independently
- Requires symbol visibility management

#### 4. Interface Component (Header-Only)

Component with no compiled code.

```cmake
add_component(mylib INTERFACE)
```

Properties:
- Headers only, no .cpp files needed
- Template-heavy code
- Zero runtime overhead
- Consumer compiles the implementation

## Component Discovery

### Automatic Discovery

When you call `add_main_component()` or `add_component()`, abcmake:

1. **Searches for `components/` directory**
2. **Finds all subdirectories** with a `CMakeLists.txt`
3. **Automatically adds** each as a subdirectory
4. **Links discovered components** to the parent

```
project/
├── CMakeLists.txt
├── src/main.cpp
└── components/
    ├── comp_a/          # Auto-discovered ✓
    │   └── CMakeLists.txt
    ├── comp_b/          # Auto-discovered ✓
    │   └── CMakeLists.txt
    └── doc_folder/      # No CMakeLists.txt - ignored
```

### Discovery Rules

Components are discovered if:

- Located under `components/` directory
- Directory contains `CMakeLists.txt`
- CMakeLists.txt calls `add_component()` or `add_main_component()`

### Recursive Discovery

Discovery works recursively - components can have sub-components:

```
components/
└── core/
    ├── CMakeLists.txt       # Defines 'core' component
    └── components/
        ├── subsystem_a/      # Auto-discovered by 'core'
        │   └── CMakeLists.txt
        └── subsystem_b/      # Auto-discovered by 'core'
            └── CMakeLists.txt
```

The `core` component automatically discovers and links `subsystem_a` and `subsystem_b`.

## The Component Registry

### What is the Registry?

The registry is a global database of component names to paths, enabling **name-based linking**.

### Why Use the Registry?

Without registry (path-based linking):
```cmake
target_link_components(myapp
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/components/logger
         ${CMAKE_CURRENT_SOURCE_DIR}/components/config
         ${CMAKE_CURRENT_SOURCE_DIR}/third_party/utils)
```

With registry (name-based linking):
```cmake
register_components(
    ${CMAKE_CURRENT_SOURCE_DIR}/components/logger
    ${CMAKE_CURRENT_SOURCE_DIR}/components/config
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/utils)

target_link_components(myapp NAME logger config utils)
```

### Registering Components

#### Manual Registration

```cmake
register_components(<path1> <path2> ...)
```

Each path should point to a component directory (containing CMakeLists.txt with `add_component()`).

#### Bulk Registration with Component Sets

```cmake
# Register all components in a directory
add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/third_party
    REGISTER_ALL)

# Register specific components
add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/libs
    COMPONENTS math utils crypto)
```

### Registry Scope

The registry is **global** within a CMake project:

- Registered once, available everywhere
- Accessible from any CMakeLists.txt
- Persists across subdirectories

## Auto Package Detection

### What is Auto Package Detection?

abcmake automatically detects and integrates vendored CMake packages.

### How It Works

Any directory under `components/` containing a `*Config.cmake` file is treated as a CMake package:

```
components/
└── fmt/
    ├── fmtConfig.cmake       # Detected as package!
    ├── include/
    └── src/
```

abcmake automatically:
1. Calls `find_package(fmt CONFIG PATHS components/fmt NO_DEFAULT_PATH)`
2. Links the target (tries `fmt` and `fmt::fmt`)
3. Makes it available to parent component

### Benefits

- Drop vendored libraries into `components/`
- Zero configuration needed
- Works with FetchContent
- Standard CMake package integration

### Example

**Project structure:**
```
project/
├── CMakeLists.txt
├── src/main.cpp
└── components/
    └── spdlog/              # Contains spdlogConfig.cmake
```

**CMakeLists.txt:**
```cmake
include(ab.cmake)
add_main_component(MyApp)
# spdlog automatically found and linked!
```

**main.cpp:**
```cpp
#include <spdlog/spdlog.h>

int main() {
    spdlog::info("Hello from auto-detected spdlog!");
}
```

## Directory Conventions

### Standard Layout

```
component/
├── CMakeLists.txt
├── src/              # Source files (.cpp, .c)
├── include/          # Public headers (.hpp, .h)
└── components/       # Sub-components
```

### Overriding Defaults

Customize with `SOURCE_DIR` and `INCLUDE_DIR`:

```cmake
add_component(mylib
    SOURCE_DIR source implementation
    INCLUDE_DIR headers public_api)
```

This searches:
- `source/` and `implementation/` for sources
- `headers/` and `public_api/` for headers

### Include Path Namespacing

**Best practice:** Namespace public headers:

```
include/
└── mycomponent/          # Component name as namespace
    ├── api.hpp
    └── utils.hpp
```

Usage:
```cpp
#include "mycomponent/api.hpp"    // Clear origin
```

Avoids:
```cpp
#include "api.hpp"                // Which API?
```

## Target Types

### Executable Targets

Created by `add_main_component()`:

```cmake
add_main_component(MyApp)
```

Produces: `MyApp` (or `MyApp.exe` on Windows)

### Static Library Targets

Created by `add_component()`:

```cmake
add_component(mylib)
```

Produces: `libmylib.a` (or `mylib.lib` on Windows)

### Shared Library Targets

Created with `SHARED` keyword:

```cmake
add_component(mylib SHARED)
```

Produces: `libmylib.so` / `mylib.dll` / `libmylib.dylib`

### Interface Library Targets

Created with `INTERFACE` keyword:

```cmake
add_component(mylib INTERFACE)
```

Produces: No binary (header-only)

## Linking Model

### Automatic Linking

Components discovered in `components/` are automatically linked:

```cmake
add_main_component(MyApp)
# All components under components/ automatically linked
```

### Manual Linking by Path

Link specific components explicitly:

```cmake
target_link_components(myapp
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/components/logger
         ${CMAKE_CURRENT_SOURCE_DIR}/components/config)
```

### Manual Linking by Name

Link using registry names:

```cmake
register_components(${CMAKE_CURRENT_SOURCE_DIR}/components/logger)

target_link_components(myapp NAME logger)
```

### Mixed Linking

Combine path and name linking:

```cmake
target_link_components(myapp
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/vendor/lib_a
    NAME logger config)
```

### Link Visibility

All component links use `PUBLIC` visibility by default:

- Component dependencies propagate to consumers
- Transitive dependencies handled automatically
- Include paths propagate through link chain

## Component Sets

### Purpose

Component sets allow you to **register** components without **building** them locally.

### Use Cases

1. **Selective Linking** - Register many, link few
2. **Third-Party Libraries** - Register vendor components
3. **Plugin Collections** - Register all plugins for discovery

### Example Scenario

You have 10 third-party components, but each project only uses 2-3:

```cmake
# Register all 10 components
add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/third_party
    REGISTER_ALL)

# Link only what this project needs
target_link_components(myapp NAME fmt spdlog)
```

Benefits:
- No need to modify third_party/CMakeLists.txt
- Only selected components are built
- Easy to add/remove dependencies

## Best Practices

### 1. One Component, One Purpose

Keep components focused:

```
✓ Good:
components/
├── json_parser/
├── xml_parser/
└── csv_parser/

✗ Avoid:
components/
└── parsers/    # Too broad, many responsibilities
```

### 2. Use Include Namespacing

Always namespace public headers:

```cpp
// Good
#include "json_parser/parser.hpp"

// Avoid
#include "parser.hpp"
```

### 3. Minimize Inter-Component Dependencies

Components should be loosely coupled:

```
✓ Good dependency tree:
app → logger → (no dependencies)
app → database → logger

✗ Avoid circular dependencies:
app → logger → database → logger  // Circular!
```

### 4. Keep Components Portable

Design components to work independently:

- No hardcoded paths outside component
- Minimal assumptions about parent project
- Clear, documented dependencies

### 5. Use Registry for Large Projects

For projects with many components, use the registry:

```cmake
# Register once at top level
add_component_set(PATH ${CMAKE_SOURCE_DIR}/libs REGISTER_ALL)

# Link by name anywhere
target_link_components(app NAME crypto network utils)
```

### 6. Version Control Components

Each component should be git-trackable:

```bash
git subtree add --prefix components/mylib https://github.com/user/mylib.git main
```

Or use submodules:

```bash
git submodule add https://github.com/user/mylib.git components/mylib
```

### 7. Document Component APIs

Each component should have clear documentation:

```
component/
├── README.md           # Component documentation
├── include/
│   └── component/
│       └── api.hpp     # Well-documented API
└── src/
```

## Summary

Understanding these concepts will help you:

- Structure projects effectively
- Leverage automatic discovery
- Manage dependencies cleanly
- Scale projects maintainably
- Integrate third-party code easily

## Next Steps

- [Quick Start](quick-start.md) - Build your first project
- [Examples](examples.md) - See concepts in action
- [API Reference](api.md) - Detailed function documentation
