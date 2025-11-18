<div align="center">

![logo](docs/README/header.drawio.svg)

Simple, component‑first CMake helper for small & medium C/C++ projects.

[![GitHub Release](https://img.shields.io/github/v/release/an-dr/abcmake?label=latest%20release)](https://github.com/an-dr/abcmake/releases)
[![Build Test](https://github.com/an-dr/abcmake/actions/workflows/test.yml/badge.svg)](https://github.com/an-dr/abcmake/actions/workflows/test.yml)

</div>

`abcmake` (Andrei's Build CMake subsystem) lets you structure a codebase as independent *components* with minimal boilerplate: drop folders under `components/`, call one function, get targets, includes, and linking done automatically.

## Why abcmake?

| Problem                                       | What abcmake Gives You                                   |
| --------------------------------------------- | -------------------------------------------------------- |
| Repeating `add_library` + globbing everywhere | Single `add_main_component()` + auto component discovery |
| Hard to reuse internal modules                | Component folders become portable units                  |
| Tedious dependency wiring                     | `target_link_components()` + optional registry by name   |
| Vendored CMake packages cumbersome            | Auto‑detect `*Config.cmake` in `components/` and link    |
| Monolithic CMakeLists.txt growth              | Split naturally by component directory                   |

## Features

- Zero external Python/CMake dependency beyond stock CMake (>= 3.15).
- Conventional project layout with overridable source/include directories.
- Automatic recursive discovery & linking of nested components.
- Registry for linking components by *name* rather than path.
- Auto-detection of vendored CMake packages (`*Config.cmake`).
- Generates `compile_commands.json` by default.
- Install step for each built target near the build dir.
- Single-file distributable (`ab.cmake`) published per GitHub Release.

## Table Of Contents

- [Why abcmake?](#why-abcmake)
- [Features](#features)
- [Table Of Contents](#table-of-contents)
- [Quick Start](#quick-start)
    - [Install](#install)
    - [Use](#use)
- [Concepts](#concepts)
- [Public API](#public-api)
    - [`add_main_component(<name> [INCLUDE_DIR ...] [SOURCE_DIR ...])`](#add_main_componentname-include_dir--source_dir-)
    - [`add_component(<name> [SHARED|INTERFACE] [INCLUDE_DIR ...] [SOURCE_DIR ...])`](#add_componentname-sharedinterface-include_dir--source_dir-)
    - [`register_components(<path> ...)`](#register_componentspath-)
    - [`target_link_components(<target> [PATH <path> ...] [NAME <comp> ...])`](#target_link_componentstarget-path-path--name-comp-)
        - [Auto Package Detection](#auto-package-detection)
- [Advanced Usage](#advanced-usage)
- [Limitations](#limitations)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

## Quick Start

### Install

**Project Scope**. Download a single-file distribution and put near your CMakeLists.txt:

- <https://github.com/an-dr/abcmake/releases>

**User Scope**. Clone the repo and install it in your system:

```bash
git clone https://github.com/you/abcmake.git
cd abcmake
cmake -B build
cmake --install build --prefix ~/.local
```

For Windows:

- Use `$env:LOCALAPPDATA\CMake` instead of `~/.local`  also append the path:

```cmake
list(APPEND CMAKE_PREFIX_PATH "$ENV{LOCALAPPDATA}/CMake")
find_package(abcmake REQUIRED)
```

**System-wide Scope**. Change prefix to `/usr/local` (Linux) or `C:\Program Files\CMake` (Windows), run with elevated privileges

```bash
git clone https://github.com/you/abcmake.git
cd abcmake
cmake -B build
sudo cmake --install build --prefix /usr/local
```

### Use

Minimal root `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.15)
project(HelloWorld)

find_package(abcmake REQUIRED) 
# or include(ab.cmake) for single-file distribution

add_main_component(${PROJECT_NAME})
```

Project layout:

```text
project/
    CMakeLists.txt
    ab.cmake
    src/
        main.cpp
    include/        (optional public headers)
    components/
        mylib/
            src/ ...
            include/ ...
            CMakeLists.txt  (uses abcmake + add_component())
```

Add a component (`components/mylib/CMakeLists.txt`):

```cmake
cmake_minimum_required(VERSION 3.15)
project(mylib)

find_package(abcmake REQUIRED)

add_component(${PROJECT_NAME})
```

## Concepts

| Term           | Meaning                                                                                    |
| -------------- | ------------------------------------------------------------------------------------------ |
| Component      | A folder with its own `CMakeLists.txt` that calls `add_component` or `add_main_component`. |
| Main component | The top-level executable (or library) defined with `add_main_component`.                   |
| Registry       | A global list of discovered components (added via `register_components`).                  |
| Auto package   | A directory under `components/` containing `*Config.cmake` -> treated as a CMake package.  |

## Public API

### `add_main_component(<name> [INCLUDE_DIR ...] [SOURCE_DIR ...])`

Creates an executable (or top-level library) and automatically:

- Adds sources from provided `SOURCE_DIR` list (default `src`).
- Adds include dirs (default `include` if exists).
- Discovers & links nested components in `components/`.

### `add_component(<name> [SHARED|INTERFACE] [INCLUDE_DIR ...] [SOURCE_DIR ...])`

Defines a static (default), shared, or interface library component with the same discovery & inclusion mechanics. Use `INTERFACE` for header-only libraries or source-distribution libraries where code compiles in the consumer's context.

### `register_components(<path> ...)`

Registers components so you can later link by name instead of path.

### `target_link_components(<target> [PATH <path> ...] [NAME <comp> ...])`

Links components to a target via explicit paths and/or previously registered names.

#### Auto Package Detection

Any directory in `components/` containing a `*Config.cmake` is probed with `find_package(<name> CONFIG PATHS <dir> NO_DEFAULT_PATH QUIET)`. Targets `<name>` or `<name>::<name>` are auto-linked if present.

## Advanced Usage

Linking multiple sources & includes:

```cmake
add_component(core \
    INCLUDE_DIR include public_api \
    SOURCE_DIR src generated)
```

Mix path + name linking:

```cmake
register_components(${CMAKE_CURRENT_LIST_DIR}/libs/math)
target_link_components(app \
    PATH ${CMAKE_CURRENT_LIST_DIR}/libs/io \
    NAME math)
```

Custom project layout (no `src/`):

```cmake
add_main_component(App SOURCE_DIR source INCLUDE_DIR include)
```

## Limitations

- One logical component per `CMakeLists.txt` (keep them focused).
- Designed for small/medium modular trees; very large monorepos may prefer native CMake patterns.

## Contributing

1. Fork & branch.
2. Run the test suite: `python -m unittest discover -v` (from `tests/`).
3. Keep PRs focused & update the **Unreleased** section in `CHANGELOG.md`.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for structured history.

## License

MIT License © Andrei Gramakov.

See [LICENSE](LICENSE) for details.
