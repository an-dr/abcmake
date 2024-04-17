# abcmake - Simple CMake for Simple Projects

![version](https://img.shields.io/badge/version-5.0.0-green)
[![Build Test](https://github.com/an-dr/abcmake/actions/workflows/test.yml/badge.svg)](https://github.com/an-dr/abcmake/actions/workflows/test.yml)

Andrei's Build CMake subsystem or `abcmake` is a CMake module to work with C/C++ project of a predefined standard structure in order to simplify the build process.
The supported project structure looks like this:

```
+📁Root Project
|
|--📁components    <------- nested abcmake projects
|  |
|  |--📁component1
|  |  |--📁include    <---- public headers
|  |  |--📁components
|  |  |--📁src    <-------- src and private headers
|  |  |--ab.cmake
|  |  '--CMakeLists.txt
|  |
|  '--📁component2
|     |--📁include
|     |--📁components
|     |--📁src
|     |--ab.cmake
|     '--CMakeLists.txt
|
|--📁include
|--📁src
|--ab.cmake
'--CMakeLists.txt
```

## Get Started

1. Create a folder i.e. `PROJECT_NAME`
2. Move all headers and sources to `PROJECT_NAME/include` and `PROJECT_NAME/src` folders respectively. All headers from `include` will be accessible to the parent project.
3. Download an [`ab.cmake`](src/ab.cmake) file to the `PROJECT_NAME` folder
4. Update your cmake file to look like this:

```cmake
cmake_minimum_required(VERSION 3.0)
project(HelloWorld)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_main_component(${PROJECT_NAME})

```

## Public Functions

- `add_main_component(TARGETNAME [INCLUDE_DIR SOURCE_DIR])` - Add the executable component. It will link all components in the **components** folder automatically. Default include and source directories are **include** and **src** respectively.
- `add_component(TARGETNAME [INCLUDE_DIR SOURCE_DIR SHARED])` - Add a component as a library
- `target_link_component (TARGETNAME COMPONENTPATH)` - Add a component to the target
- `target_sources_directory(TARGETNAME SOURCE_DIR)` - Add all sources from the directory

If you want to use the module in your project, you can use the badge:

[![abcmake](https://img.shields.io/badge/uses-abcmake-blue)](https://github.com/an-dr/abcmake)
