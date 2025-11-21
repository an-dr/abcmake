# Examples and Usage Patterns

This guide provides real-world examples and common usage patterns for abcmake projects.

## Table of Contents

- [Basic Examples](#basic-examples)
  - [Simple Executable](#simple-executable)
  - [Executable with Libraries](#executable-with-libraries)
  - [Header-Only Library](#header-only-library)
  - [Shared Library](#shared-library)
- [Component Organization](#component-organization)
  - [Nested Components](#nested-components)
  - [Multiple Components](#multiple-components)
  - [Cross-Component Dependencies](#cross-component-dependencies)
- [Advanced Patterns](#advanced-patterns)
  - [Component Registry](#component-registry)
  - [Component Sets](#component-sets)
  - [Custom Directory Layout](#custom-directory-layout)
  - [Third-Party Integration](#third-party-integration)
- [Real-World Projects](#real-world-projects)
  - [CLI Application](#cli-application)
  - [Plugin Architecture](#plugin-architecture)
  - [Embedded System](#embedded-system)

## Basic Examples

### Simple Executable

The simplest possible project - just a main executable.

**Project Structure:**
```
simple_app/
├── CMakeLists.txt
├── ab.cmake
└── src/
    └── main.cpp
```

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(SimpleApp)

include(ab.cmake)
add_main_component(${PROJECT_NAME})
```

**src/main.cpp:**
```cpp
#include <iostream>

int main() {
    std::cout << "Simple app!" << std::endl;
    return 0;
}
```

### Executable with Libraries

Application with internal library components.

**Project Structure:**
```
app_with_libs/
├── CMakeLists.txt
├── ab.cmake
├── src/
│   └── main.cpp
└── components/
    ├── math/
    │   ├── CMakeLists.txt
    │   ├── include/math/
    │   │   └── calculator.hpp
    │   └── src/
    │       └── calculator.cpp
    └── utils/
        ├── CMakeLists.txt
        ├── include/utils/
        │   └── logger.hpp
        └── src/
            └── logger.cpp
```

**Root CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(AppWithLibs)

include(ab.cmake)
add_main_component(${PROJECT_NAME})
```

**components/math/CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(math)

include(../../ab.cmake)
add_component(${PROJECT_NAME})
```

**components/math/include/math/calculator.hpp:**
```cpp
#pragma once

class Calculator {
public:
    static int add(int a, int b);
    static int multiply(int a, int b);
};
```

**components/math/src/calculator.cpp:**
```cpp
#include "math/calculator.hpp"

int Calculator::add(int a, int b) {
    return a + b;
}

int Calculator::multiply(int a, int b) {
    return a * b;
}
```

**src/main.cpp:**
```cpp
#include <iostream>
#include "math/calculator.hpp"
#include "utils/logger.hpp"

int main() {
    Logger::log("Starting application");

    int result = Calculator::add(5, 3);
    Logger::log("5 + 3 = " + std::to_string(result));

    return 0;
}
```

### Header-Only Library

Creating a header-only component.

**components/algorithms/CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(algorithms)

include(../../ab.cmake)
add_component(${PROJECT_NAME} INTERFACE)
```

**components/algorithms/include/algorithms/sort.hpp:**
```cpp
#pragma once
#include <vector>
#include <algorithm>

namespace algorithms {

template<typename T>
void quicksort(std::vector<T>& data) {
    std::sort(data.begin(), data.end());
}

template<typename T>
T find_max(const std::vector<T>& data) {
    return *std::max_element(data.begin(), data.end());
}

} // namespace algorithms
```

**Usage in main.cpp:**
```cpp
#include <iostream>
#include <vector>
#include "algorithms/sort.hpp"

int main() {
    std::vector<int> numbers = {5, 2, 8, 1, 9};

    algorithms::quicksort(numbers);
    int max = algorithms::find_max(numbers);

    std::cout << "Max: " << max << std::endl;
    return 0;
}
```

### Shared Library

Creating a component as a shared/dynamic library.

**components/plugin/CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(plugin)

include(../../ab.cmake)
add_component(${PROJECT_NAME} SHARED)

# Export symbols on Windows
if(WIN32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE PLUGIN_EXPORTS)
endif()
```

**components/plugin/include/plugin/api.hpp:**
```cpp
#pragma once

#ifdef _WIN32
    #ifdef PLUGIN_EXPORTS
        #define PLUGIN_API __declspec(dllexport)
    #else
        #define PLUGIN_API __declspec(dllimport)
    #endif
#else
    #define PLUGIN_API
#endif

class PLUGIN_API PluginInterface {
public:
    virtual ~PluginInterface() = default;
    virtual void execute() = 0;
};

extern "C" PLUGIN_API PluginInterface* create_plugin();
extern "C" PLUGIN_API void destroy_plugin(PluginInterface* plugin);
```

## Component Organization

### Nested Components

Components can have their own sub-components.

**Project Structure:**
```
project/
├── CMakeLists.txt
├── src/main.cpp
└── components/
    └── core/
        ├── CMakeLists.txt
        ├── src/core.cpp
        ├── include/core/core.hpp
        └── components/
            ├── subsystem_a/
            │   ├── CMakeLists.txt
            │   └── ...
            └── subsystem_b/
                ├── CMakeLists.txt
                └── ...
```

**components/core/CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(core)

include(../../ab.cmake)
add_component(${PROJECT_NAME})

# Nested components are automatically discovered and linked
```

### Multiple Components

Managing multiple independent components.

**Project Structure:**
```
multi_component_app/
├── CMakeLists.txt
├── src/main.cpp
└── components/
    ├── database/
    │   ├── CMakeLists.txt
    │   └── ...
    ├── networking/
    │   ├── CMakeLists.txt
    │   └── ...
    ├── ui/
    │   ├── CMakeLists.txt
    │   └── ...
    └── config/
        ├── CMakeLists.txt
        └── ...
```

All components are automatically discovered and linked to the main component.

### Cross-Component Dependencies

One component depending on another.

**components/http_server/CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(http_server)

include(../../ab.cmake)
add_component(${PROJECT_NAME})

# Explicitly link to networking component
target_link_components(${PROJECT_NAME}
    PATH ${CMAKE_CURRENT_LIST_DIR}/../networking)
```

## Advanced Patterns

### Component Registry

Using the component registry for name-based linking.

**Root CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp)

include(ab.cmake)

# Register components by path
register_components(
    ${CMAKE_CURRENT_SOURCE_DIR}/components/core
    ${CMAKE_CURRENT_SOURCE_DIR}/components/utils
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/vendor_lib
)

add_main_component(${PROJECT_NAME})

# Link by name instead of path
target_link_components(${PROJECT_NAME}
    NAME core utils vendor_lib)
```

### Component Sets

Bulk registration without creating local targets.

**Scenario:** You have many third-party components but only need some.

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp)

include(ab.cmake)

# Register all third-party components without building them here
add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/third_party
    REGISTER_ALL)

add_main_component(${PROJECT_NAME})

# Now link only what you need
target_link_components(${PROJECT_NAME}
    NAME fmt spdlog json)
```

**Alternative - Register specific components:**
```cmake
add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/third_party
    COMPONENTS fmt spdlog json)
```

### Custom Directory Layout

Adapting abcmake to non-standard layouts.

**Project Structure:**
```
legacy_project/
├── CMakeLists.txt
├── source/           # Not "src/"
│   └── main.cpp
├── headers/          # Not "include/"
│   └── app.hpp
└── modules/          # Not "components/"
    └── legacy_lib/
        └── ...
```

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(LegacyApp)

include(ab.cmake)

# Specify custom directories
add_main_component(${PROJECT_NAME}
    SOURCE_DIR source
    INCLUDE_DIR headers)

# Manually discover components in non-standard location
target_link_components(${PROJECT_NAME}
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/modules/legacy_lib)
```

### Third-Party Integration

#### Vendored CMake Package

**Project Structure:**
```
project/
├── CMakeLists.txt
├── src/main.cpp
└── components/
    └── fmt/              # Contains fmtConfig.cmake
        ├── include/
        ├── src/
        └── fmtConfig.cmake
```

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp)

include(ab.cmake)
add_main_component(${PROJECT_NAME})

# fmt is auto-detected and linked via find_package
```

**main.cpp:**
```cpp
#include <fmt/core.h>

int main() {
    fmt::print("Hello, {}!\n", "world");
    return 0;
}
```

#### FetchContent Integration

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp)

include(FetchContent)
include(ab.cmake)

# Fetch external dependency
FetchContent_Declare(
    json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.11.2
)
FetchContent_MakeAvailable(json)

add_main_component(${PROJECT_NAME})

# Link external dependency
target_link_libraries(${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json)
```

## Real-World Projects

### CLI Application

A command-line tool with multiple modules.

**Project Structure:**
```
cli_tool/
├── CMakeLists.txt
├── src/main.cpp
└── components/
    ├── cli_parser/
    │   ├── CMakeLists.txt
    │   ├── include/cli_parser/
    │   │   └── parser.hpp
    │   └── src/parser.cpp
    ├── file_processor/
    │   ├── CMakeLists.txt
    │   └── ...
    └── output_formatter/
        ├── CMakeLists.txt
        └── ...
```

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(CliTool)

include(ab.cmake)

# Main executable
add_main_component(${PROJECT_NAME})

# All components auto-discovered and linked
```

**src/main.cpp:**
```cpp
#include <iostream>
#include "cli_parser/parser.hpp"
#include "file_processor/processor.hpp"
#include "output_formatter/formatter.hpp"

int main(int argc, char* argv[]) {
    CliParser parser;
    auto options = parser.parse(argc, argv);

    FileProcessor processor(options);
    auto results = processor.process();

    OutputFormatter formatter;
    formatter.format(results);

    return 0;
}
```

### Plugin Architecture

Application that loads plugins dynamically.

**Project Structure:**
```
plugin_app/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   └── plugin_manager.cpp
├── include/
│   └── plugin_interface.hpp
└── plugins/
    ├── plugin_a/
    │   ├── CMakeLists.txt
    │   └── src/plugin_a.cpp
    └── plugin_b/
        ├── CMakeLists.txt
        └── src/plugin_b.cpp
```

**Root CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(PluginApp)

include(ab.cmake)

# Main application
add_main_component(${PROJECT_NAME})

# Don't auto-link plugins; they'll be loaded dynamically
# But register them for compilation
add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/plugins
    REGISTER_ALL)
```

**plugins/plugin_a/CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(plugin_a)

include(../../ab.cmake)

# Create shared library
add_component(${PROJECT_NAME} SHARED)

# Link to main app's interface
target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../include)
```

### Embedded System

Firmware project for embedded systems.

**Project Structure:**
```
firmware/
├── CMakeLists.txt
├── src/main.c
└── components/
    ├── hal/              # Hardware abstraction
    │   ├── CMakeLists.txt
    │   └── ...
    ├── drivers/          # Device drivers
    │   ├── CMakeLists.txt
    │   └── ...
    └── rtos/             # RTOS components
        ├── CMakeLists.txt
        └── ...
```

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(Firmware C)

# Set target architecture
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)

include(ab.cmake)

add_main_component(${PROJECT_NAME})

# Add embedded-specific flags
target_compile_options(${PROJECT_NAME} PRIVATE
    -mcpu=cortex-m4
    -mthumb
    -Wall -Werror
)

target_link_options(${PROJECT_NAME} PRIVATE
    -T${CMAKE_CURRENT_SOURCE_DIR}/linker_script.ld
)
```

## Tips and Best Practices

### Organizing Large Projects

```
large_project/
├── CMakeLists.txt
├── apps/                 # Multiple executables
│   ├── server/
│   │   ├── CMakeLists.txt
│   │   └── src/main.cpp
│   └── client/
│       ├── CMakeLists.txt
│       └── src/main.cpp
├── libs/                 # Shared components
│   └── components/
│       ├── core/
│       ├── network/
│       └── utils/
└── third_party/          # External dependencies
    └── components/
        ├── fmt/
        └── spdlog/
```

**Root CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.15)
project(LargeProject)

include(ab.cmake)

# Register all shared libraries
add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/libs/components
    REGISTER_ALL)

add_component_set(
    PATH ${CMAKE_CURRENT_SOURCE_DIR}/third_party/components
    REGISTER_ALL)

# Build applications
add_subdirectory(apps/server)
add_subdirectory(apps/client)
```

### Testing Integration

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject)

include(ab.cmake)

# Production code
add_main_component(${PROJECT_NAME})

# Testing
if(BUILD_TESTING)
    enable_testing()

    # Test executable with access to components
    add_executable(unit_tests tests/test_main.cpp)

    # Link same components as main app
    target_link_components(unit_tests
        PATH ${CMAKE_CURRENT_SOURCE_DIR}/components/math
             ${CMAKE_CURRENT_SOURCE_DIR}/components/utils)

    add_test(NAME unit_tests COMMAND unit_tests)
endif()
```

## Next Steps

- [API Reference](api.md) - Detailed function documentation
- [Concepts](concepts.md) - Understand the underlying model
- [Contributing](../CONTRIBUTING.md) - Contribute your own examples
