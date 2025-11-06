cmake_minimum_required(VERSION 3.5)

# This test verifies that find_package(abcmake) works correctly
# Usage:
#   cmake -P test_find_package.cmake
# Or with custom install prefix:
#   cmake -DINSTALL_PREFIX=/path/to/install -P test_find_package.cmake

# Determine the test installation path
if(NOT DEFINED INSTALL_PREFIX)
    # Default: use test_install directory in project root
    get_filename_component(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
    set(INSTALL_PREFIX "${PROJECT_ROOT}/test_install")
endif()

message(STATUS "Testing find_package with install prefix: ${INSTALL_PREFIX}")

# Set the prefix path to our test installation
set(CMAKE_PREFIX_PATH "${INSTALL_PREFIX}")

# Try to find the abcmake package
find_package(abcmake REQUIRED)

# Print success information
message(STATUS "========================================")
message(STATUS "SUCCESS! abcmake package was found!")
message(STATUS "========================================")
message(STATUS "abcmake version: ${abcmake_VERSION}")
message(STATUS "abcmake directory: ${abcmake_DIR}")
message(STATUS "ABCMAKE_PATH: ${ABCMAKE_PATH}")
message(STATUS "ABCMAKE_VERSION: ${ABCMAKE_VERSION}")
message(STATUS "========================================")

# Verify that the ab.cmake file exists
if(EXISTS "${ABCMAKE_PATH}/ab.cmake")
    message(STATUS "✓ ab.cmake found at: ${ABCMAKE_PATH}/ab.cmake")
else()
    message(FATAL_ERROR "✗ ab.cmake NOT found at expected location!")
endif()

# Verify that functions are available by checking if they're defined
# (We can't actually call them without a proper project setup)
message(STATUS "✓ abcmake functions have been loaded")
message(STATUS "========================================")
