# API Reference

- [API Reference](#api-reference)
    - [add\_main\_component](#add_main_component)
    - [add\_component](#add_component)
    - [add\_component\_set](#add_component_set)
    - [register\_components](#register_components)
    - [target\_link\_components](#target_link_components)

## add_main_component

```cmake
add_main_component(<name> [INCLUDE_DIR ...] [SOURCE_DIR ...])
```

Creates the top-level executable (or library) and discovers nested components under `components/`.

- Defaults: `SOURCE_DIR src`, `INCLUDE_DIR include` (if it exists).
- Includes each `SOURCE_DIR` and adds include paths; links discovered components automatically.

Example:

```cmake
add_main_component(my_app
    INCLUDE_DIR include public_api
    SOURCE_DIR src core)
```

## add_component

```cmake
add_component(<name> [SHARED|INTERFACE] [INCLUDE_DIR ...] [SOURCE_DIR ...])
```

Defines a library component with the same discovery/linking as `add_main_component`.

- Static by default; `SHARED` for shared libs; `INTERFACE` for header-only/consumer-built sources.
- Adds include dirs and sources, then installs the target (non-interface).

Example:

```cmake
add_component(driver SHARED SOURCE_DIR drivers)
add_component(utils INTERFACE)  # header-only
```

## add_component_set

```cmake
add_component_set([PATH <path>] [COMPONENTS <names>...] [REGISTER_ALL])
```

Registers a group of components without creating a local target—useful for plugin/dependency bundles.

- `PATH` defaults to the configured components dir.
- `COMPONENTS` lists subdirectories to register; `REGISTER_ALL` sweeps all subdirs under `PATH`.

Example:

```cmake
add_component_set(REGISTER_ALL)  # register every subdir under components

add_component_set(
    PATH third_party
    COMPONENTS fmt spdlog)       # register specific subdirs third_party
```

## register_components

```cmake
register_components(<paths> ...)
```

Adds components to the global registry so they can be linked by name.

- Use before `target_link_components(NAME ...)`.

Example:

```cmake
register_components(
    ${CMAKE_CURRENT_LIST_DIR}/libs 
    ${CMAKE_CURRENT_LIST_DIR}/3rd_party)
```

## target_link_components

```cmake
target_link_components(<target> [PATH <paths> ...] [NAME <comps> ...])
```

Links dependencies into `<target>` by path and/or registered name.

- Path entries look for abcmake components or raw CMake packages (`*Config.cmake`).
- Name entries resolve via the registry (from `register_components`).

Example:

```cmake
target_link_components(
    app
    PATH ${CMAKE_CURRENT_LIST_DIR}/vendor
         ${CMAKE_CURRENT_LIST_DIR}/libs 
    NAME logger 
         crypto)
```
