# abcmake

<div align="center">

Simple, component‑first CMake helper for small & medium C/C++ projects.

[![GitHub Release](https://img.shields.io/github/v/release/an-dr/abcmake?label=latest%20release)](https://github.com/an-dr/abcmake/releases)
[![Build Test](https://github.com/an-dr/abcmake/actions/workflows/test.yml/badge.svg)](https://github.com/an-dr/abcmake/actions/workflows/test.yml)

</div>

`abcmake` (Andrei's Build CMake subsystem) lets you structure a codebase as independent *components* with minimal boilerplate: drop folders under `components/`, call one function, get targets, includes, and linking done automatically.

## Why abcmake?

| Problem | What abcmake Gives You |
|---------|------------------------|
| Repeating `add_library` + globbing everywhere | Single `add_main_component()` + auto component discovery |
| Hard to reuse internal modules | Component folders become portable units |
| Tedious dependency wiring | `target_link_components()` + optional registry by name |
| Vendored CMake packages cumbersome | Auto‑detect `*Config.cmake` in `components/` and link |
| Monolithic CMakeLists.txt growth | Split naturally by component directory |

## Features

- Zero external Python/CMake dependency beyond stock CMake (>= 3.5).
- Conventional project layout with overridable source/include directories.
- Automatic recursive discovery & linking of nested components.
- Registry for linking components by *name* rather than path.
- Auto-detection of vendored CMake packages (`*Config.cmake`).
- Generates `compile_commands.json`.
- Install step for each built target near the build dir.
- Single-file distributable (`ab.cmake`) published per GitHub Release.

- [abcmake](#abcmake)
    - [Why abcmake?](#why-abcmake)
    - [Features](#features)
    - [Installation - Single File](#installation---single-file)
    - [Installation - Packaged](#installation---packaged)
        - [Automated (All Platforms)](#automated-all-platforms)
        - [Environment Setup](#environment-setup)
            - [Linux/macOS](#linuxmacos)
            - [Windows (PowerShell)](#windows-powershell)
    - [Quick Start](#quick-start)
    - [Concepts](#concepts)
    - [Public API](#public-api)
        - [`add_main_component(<name> [INCLUDE_DIR ...] [SOURCE_DIR ...])`](#add_main_componentname-include_dir--source_dir-)
        - [`add_component(<name> [SHARED] [INCLUDE_DIR ...] [SOURCE_DIR ...])`](#add_componentname-shared-include_dir--source_dir-)
        - [`register_components(<path> ...)`](#register_componentspath-)
        - [`target_link_components(<target> [PATH <path> ...] [NAME <comp> ...])`](#target_link_componentstarget-path-path--name-comp-)
            - [Auto Package Detection](#auto-package-detection)
    - [Advanced Usage](#advanced-usage)
    - [Configuration](#configuration)
    - [Limitations](#limitations)
    - [Release \& Single-File Build](#release--single-file-build)
    - [Contributing](#contributing)
    - [Changelog](#changelog)
    - [License](#license)

## Installation - Single File

1. Download `ab.cmake` from the latest [GitHub Release](https://github.com/an-dr/abcmake/releases).
2. Place it at your project root next to `CMakeLists.txt`.
3. `include(ab.cmake)` in your root `CMakeLists.txt`.

Optional (submodules / vendored): you can also keep the whole repository and include via `set(ABCMAKE_PATH path/to/src)` & `include(${ABCMAKE_PATH}/ab.cmake)`.

## Installation - Packaged

### Automated (All Platforms)

```bash
# Extract and run installer
unzip abcmake-package-v6_2_1.zip
cd abcmake-package-v6_2_1
cmake -P install.cmake
```

**Installation paths:**
- **Linux/Unix**: `~/.local/share/cmake/abcmake`
- **macOS**: `~/Library/Application Support/CMake/share/cmake/abcmake`
- **Windows**: `%APPDATA%/CMake/share/cmake/abcmake`

### Environment Setup

#### Linux/macOS

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export CMAKE_PREFIX_PATH="$HOME/.local:$CMAKE_PREFIX_PATH"  # Linux
export CMAKE_PREFIX_PATH="$HOME/Library/Application Support/CMake:$CMAKE_PREFIX_PATH"  # macOS
```

#### Windows (PowerShell)

Add to your CMakeLists.txt:

```cmake
list(APPEND CMAKE_PREFIX_PATH "$ENV{APPDATA}/CMake")
```

Or set permanently in PowerShell profile:

    
```powershell
$env:CMAKE_PREFIX_PATH = "$env:APPDATA\CMake;$env:CMAKE_PREFIX_PATH"
```

## Quick Start

Minimal root `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.15)
project(HelloWorld)
find_package(abcmake REQUIRED) # or include(ab.cmake) for single-file
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
include($ENV{ABCMAKE_PATH}/ab.cmake) # or relative path if local copy
add_component(${PROJECT_NAME})
```

## Concepts

| Term | Meaning |
|------|---------|
| Component | A folder with its own `CMakeLists.txt` that calls `add_component` or `add_main_component`. |
| Main component | The top-level executable (or library) defined with `add_main_component`. |
| Registry | A global list of discovered components (added via `register_components`). |
| Auto package | A directory under `components/` containing `*Config.cmake` -> treated as a CMake package. |

## Public API

### `add_main_component(<name> [INCLUDE_DIR ...] [SOURCE_DIR ...])`

Creates an executable (or top-level library) and automatically:

- Adds sources from provided `SOURCE_DIR` list (default `src`).
- Adds include dirs (default `include` if exists).
- Discovers & links nested components in `components/`.

### `add_component(<name> [SHARED] [INCLUDE_DIR ...] [SOURCE_DIR ...])`

Defines a static (default) or shared library component with the same discovery & inclusion mechanics.

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

## Configuration

Environment variables:

| Variable | Effect |
|----------|--------|
| `ABCMAKE_EMOJI=1` | Fancy emoji output in logs. |

## Limitations

- One logical component per `CMakeLists.txt` (keep them focused).
- Designed for small/medium modular trees; very large monorepos may prefer native CMake patterns.

## Release & Single-File Build

The single-file `ab.cmake` is generated automatically during tagged releases (`v*.*.*`). It is not stored in the repository.

Generate locally:

```bash
python scripts/build_single_file.py
```

Download instead: [GitHub Releases](https://github.com/an-dr/abcmake/releases)

## Contributing

1. Fork & branch.
2. Run the test suite: `python -m unittest discover -v` (from `tests/`).
3. Regenerate single file if you touch core logic: `python scripts/build_single_file.py` (optional for dev).
4. Keep PRs focused & update the **Unreleased** section in `CHANGELOG.md`.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for structured history.

## License

MIT License © Andrei Gramakov.

See [LICENSE](LICENSE) for details.
