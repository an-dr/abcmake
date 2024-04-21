# *************************************************************************
#
# Copyright (c) 2024 Andrei Gramakov. All rights reserved.
#
# This file is licensed under the terms of the MIT license.  
# For a copy, see: https://opensource.org/licenses/MIT
#
# site:    https://agramakov.me
# e-mail:  mail@agramakov.me
#
# Andrei's Build CMake subsystem or abcmake is a CMake module to work 
# with C/C++ project of a predefined standard structure in order to 
# simplify the build process.
# 
# Source Code: https://github.com/an-dr/abcmake
# *************************************************************************

include(${CMAKE_CURRENT_LIST_DIR}/abcmake/version.cmake)

# Configure CMake
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

include(CMakeParseArguments)

# *************************************************************************
# Private functions
# *************************************************************************

include(${CMAKE_CURRENT_LIST_DIR}/abcmake/private.cmake)

# *************************************************************************
# Public functions
# *************************************************************************

# Add all source files from the specified directory to the target
# @param TARGETNAME - name of the target to add sources
function(target_sources_directory TARGETNAME SOURCE_DIR)
    file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.cpp" "${SOURCE_DIR}/*.c")
    message( DEBUG "${TARGETNAME} sources: ${SOURCES}")
    target_sources(${TARGETNAME} PRIVATE ${SOURCES})
endfunction()


# Link the component to the target
# @param TARGETNAME - name of the target for linking
# @param COMPONENTPATH - path to the component to link
function (target_link_component TARGETNAME COMPONENTPATH)
    _abc_AddProject(${COMPONENTPATH} ver)
    if (ver)
        get_directory_property(to_link DIRECTORY ${COMPONENTPATH} ABCMAKE_TARGETS)
        message (STATUS "  ✅ Linking ${to_link} to ${TARGETNAME}")
        target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
    endif()
endfunction()

# Add an executable component to the project
# @param TARGETNAME - name of the target to add the component
# @param INCLUDE_DIR - path to the include directory
# @param SOURCE_DIR - path to the source directory
function(add_main_component TARGETNAME)
    set(flags)
    set(args)
    set(listArgs INCLUDE_DIR SOURCE_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    if (NOT arg_SOURCE_DIR)
        set(arg_SOURCE_DIR "src")
    endif()
    
    if (NOT arg_INCLUDE_DIR)
        set(arg_INCLUDE_DIR "include")
    endif()
    
    add_executable(${TARGETNAME})
    _target_init_abcmake(${TARGETNAME} ${arg_INCLUDE_DIR} ${arg_SOURCE_DIR})
    _target_install_near_build(${TARGETNAME} ".")
endfunction()

# Add a shared or static library component to the project
# @param TARGETNAME - name of the target to add the component
# @param INCLUDE_DIR - path to the include directory
# @param SOURCE_DIR - path to the source directory
# @param SHARED - if set to TRUE, the library will be shared
function(add_component TARGETNAME)
    set(flags SHARED)
    set(args)
    set(listArgs INCLUDE_DIR SOURCE_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    if (NOT arg_SOURCE_DIR)
        set(arg_SOURCE_DIR "src")
    endif()

    if (NOT arg_INCLUDE_DIR)
        set(arg_INCLUDE_DIR "include")
    endif()

    if (arg_SHARED)
        add_library(${TARGETNAME} SHARED)
    else()
        add_library(${TARGETNAME} STATIC)
    endif()
    
    _target_init_abcmake(${TARGETNAME} ${arg_INCLUDE_DIR} ${arg_SOURCE_DIR})
    _target_install_near_build(${TARGETNAME} "lib")
endfunction()
