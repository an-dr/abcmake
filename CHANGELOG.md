# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- ...


## [6.2.0] - 2025-09-17

### Added

- Automatic detection and linking of vendored CMake packages via `*Config.cmake` inside `components/`.
- Release generation workflow (`release.yml`) producing single-file `ab.cmake` as a GitHub Release asset (no longer committed to repo).

### Changed

- Removed committed `release/ab.cmake` from repository; distribution now via CI artifacts only.
- Internal linking logic split into `_abcmake_try_link_abcmake_component` and `_abcmake_try_link_cmake_package`.
- README download instructions now point to GitHub Releases.

### Removed

- Freshness check step for committed release file in test workflow (artifact no longer tracked).

### Fixed

- Markdown lint issues in README (fenced code languages, bare URLs, spacing).

## [6.1.0] - 2024-05-10

### Added

- `register_components` function to allow linking by component names (#14).
- Property helper functions refactor (#13).
- Support for multiple values in `INCLUDE_DIR` and `SOURCE_DIR` arguments (#12).
- Python unit tests harness (#11).
- `target_link_components` public function for batch linking (#10).

### Changed

- Split `ab.cmake` into modular internal files for development (#6).
- Interface revamp for simplicity (#3).
- Reimplementation as a CMake module with public functions for better compatibility (#1).

### Fixed

- Typos and documentation corrections across README.
- Added protection against adding the same project twice.

## [6.0.0] - 2024-04-18

### Added

- New public functions for non-standard project structures (#2).

### Changed

- Large interface overhaul (precursor to 6.1 improvements).

## [5.0.0] - 2020-09-18

### Changed

- Major refactor and internal cleanup.

## [4.0.0] - 2019-07-21

### Added

- Search in include and src folders.
- Install scripts and copying of sources during installation.

## [3.0.0] - 2019-07-20

### Added

- Initial README and project restructuring.

## [2.0.0] - 2019-07-19

### Added

- Initial CMake build setup.

## [1.0.0] - 2019-07-19

### Added

- First commit / project bootstrap.
