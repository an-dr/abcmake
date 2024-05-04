# abcmake - Simple CMake for Simple Projects

![version](https://img.shields.io/badge/version-5.2.0-green)
[![Build Test](https://github.com/an-dr/abcmake/actions/workflows/test.yml/badge.svg)](https://github.com/an-dr/abcmake/actions/workflows/test.yml)

`abcmake` or **Andrei's Build CMake subsystem** is a CMake module to work with C/C++ project of a predefined standard structure in order to simplify the build process.

[![version](https://img.shields.io/badge/Download-ab.cmake-blue)](release/ab.cmake)

The supported project structure looks like this:

```
+📁Root Project
|
|--+📁components    <------- nested abcmake projects
|  |
|  |--+📁component1
|  |  |---📁include    <---- public headers
|  |  |---📁components
|  |  |---📁src    <-------- src and private headers
|  |  |---ab.cmake
|  |  '--CMakeLists.txt
|  |
|  '--+📁component2
|     |---📁include
|     |---📁components
|     |---📁src
|     |---ab.cmake
|     '--CMakeLists.txt
|
|---📁include
|---📁src
|---ab.cmake
'--CMakeLists.txt
```

## Table of Contents


- [abcmake - Simple CMake for Simple Projects](#abcmake---simple-cmake-for-simple-projects)
    - [Table of Contents](#table-of-contents)
    - [Quick Start](#quick-start)
    - [Public Functions](#public-functions)
    - [Real Life Example (abcmake v5.1.1)](#real-life-example-abcmake-v511)

## Quick Start

1. Create a folder i.e. `PROJECT_NAME`
2. Move all headers and sources to `PROJECT_NAME/include` and `PROJECT_NAME/src` folders respectively. All headers from `include` will be accessible to the parent project.
3. Download an [`ab.cmake`](release/ab.cmake) file to the `PROJECT_NAME` folder
4. Update your cmake file to look like this:

```cmake
cmake_minimum_required(VERSION 3.5) # abcmake requirement
project(HelloWorld)

include(ab.cmake)
add_main_component(${PROJECT_NAME})

```

If you want to use the module in your project, you can use the badge:

[![abcmake](https://img.shields.io/badge/uses-abcmake-blue)](https://github.com/an-dr/abcmake)

```markdown
[![abcmake](https://img.shields.io/badge/uses-abcmake-blue)](https://github.com/an-dr/abcmake)
```

## Public Functions

The module provides tree powerfull functions, fully compatible with the standard CMake. 

- **`add_main_component(TARGETNAME [INCLUDE_DIR] [SOURCE_DIR])`** - Add an executable target. Create a  It will link all components in the **components** folder automatically. Default include and source directories are **include** and **src** respectively. You can override them with your custom list of directories.
- **`add_component(TARGETNAME [INCLUDE_DIR] [SOURCE_DIR] [SHARED])`** - Add a library target. Works similarly to `add_main_component`
- **`target_link_components (TARGETNAME COMPONENT_DIR)`** - Add components to the target. Can be used for linking components from custom directories and linking components between each other. Accepts a list of values.


## Real Life Example (abcmake v5.1.1)

Lets see the file structure of on of my projects:

```txt
📦VisioneR
 |--+📁components
 |  |--+📁object_finder
 |  |  |--+📁include
 |  |  |  '--ObjectFinder.hpp
 |  |  |--+📁src
 |  |  |  '--ObjectFinder.cpp
 |  |  '--🔷CMakeLists.txt
 |  |
 |  '--+📁visioner_base
 |  |  |--+📁include
 |  |  |  '--+📁App
 |  |  |  |  |--App.hpp
 |  |  |  |  |--FaceInterface.hpp
 |  |  |  |  '--InputInterface.hpp
 |  |  |--+📁src
 |  |  |  '--App.cpp
 |  |  |--🔷CMakeLists.txt
 |  |  '--README.md
 |  | 
 |--+📁src
 |  |--+📁VisionerFile
 |  |  |--AppVisioner.cpp
 |  |  |--AppVisioner.hpp
 |  |  |--Face.cpp
 |  |  |--Face.hpp
 |  |  |--FileScanner.cpp
 |  |  |--FileScanner.hpp
 |  |  |--InputFiles.cpp
 |  |  |--InputFiles.hpp
 |  |  |--README.md
 |  |  '--main.cpp
 |  '--+📁VisionerWebcam
 |  |  |--AppVisioner.cpp
 |  |  |--AppVisioner.hpp
 |  |  |--Face.cpp
 |  |  |--Face.hpp
 |  |  |--FileScanner.cpp
 |  |  |--FileScanner.hpp
 |  |  |--InputWebcam.cpp
 |  |  |--InputWebcam.hpp
 |  |  '--main.cpp
 |--🔷CMakeLists.txt
 '--ab.cmake
 ```

How much time would it take to write a CMakeLists.txt for this project? With `abcmake` it is just several lines:

First component:

```cmake
cmake_minimum_required(VERSION 3.5)
project(object_finder)

include(${CMAKE_CURRENT_LIST_DIR}/../../ab.cmake)
add_component(object_finder)
```

...second:

```cmake
cmake_minimum_required(VERSION 3.5)
project(visioner_base)

include(${CMAKE_CURRENT_LIST_DIR}/../../ab.cmake)
add_component(visioner_base)
target_link_component(visioner_base ${CMAKE_CURRENT_LIST_DIR}/../object_finder)
```

...and the main project:

```cmake
cmake_minimum_required(VERSION 3.15)
project(visioner)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

# OpenCV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# Executable
include(ab.cmake)
add_main_component(VisionerFile SOURCE_DIR "src/VisionerFile")
target_link_libraries(VisionerFile PRIVATE ${OpenCV_LIBS})

add_main_component(VisionerWebcam SOURCE_DIR "src/VisionerWebcam")
target_link_libraries(VisionerWebcam PRIVATE ${OpenCV_LIBS})
```

That's it! The project is ready to be built. The `abcmake` will take care of the rest. All the binaries will be installed along with the `build` directory.
