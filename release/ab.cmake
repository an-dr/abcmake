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

set(ABCMAKE_VERSION_MAJOR 5)
set(ABCMAKE_VERSION_MINOR 3)
set(ABCMAKE_VERSION_PATCH 1)
set(ABCMAKE_VERSION "${ABCMAKE_VERSION_MAJOR}.${ABCMAKE_VERSION_MINOR}.${ABCMAKE_VERSION_PATCH}")


# Configure CMake
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# ----------------------------------------------------------------------------
# Internal CMake modules
# ----------------------------------------------------------------------------

# ==============================================================================
# abcmake_property.cmake =======================================================

# A change in any of these variables will cause a breaking change in the API!

set(ABCMAKE_PROPERTY_PREFIX "ABCMAKE_")

# Global properties:
set(ABCMAKE_PROP_ADDED_PROJECTS "ADDED_PROJECTS") # The list of projects that have been added to the solution
set(_ABCMAKE_PROP_COMPONENTS_DIR "COMPONENTS_DIR") # The directory where the components are stored
set(_ABCMAKE_PROP_SRC_DIR "SRC_DIR") # The directory where the source files are stored
set(_ABCMAKE_PROP_INCLUDE_DIR "INCLUDE_DIR") # The directory where the include files are stored
set(_ABCMAKE_PROP_INSTALL_DIR "INSTALL_DIR") # The directory where the project will be installed

# Directory-scope properties
set(ABCMAKE_DIRPROP_VERSION "VERSION") # The abcmake version of the component
set(ABCMAKE_DIRPROP_TARGETS "TARGETS") # The list of targets built by the component

# Default values
set(_ABCMAKE_DEFAULT_COMPONENTS_DIR "components")
set(_ABCMAKE_DEFAULT_SRC_DIR "src")
set(_ABCMAKE_DEFAULT_INCLUDE_DIR "include")
set(_ABCMAKE_DEFAULT_INSTALL_DIR "${CMAKE_BINARY_DIR}/../install")

# Setters
# =======

function(_abcmake_set_prop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_abcmake_append_prop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_abcmake_set_prop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_directory_properties(PROPERTIES
                             ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_abcmake_append_prop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} 
                 APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()


# Getters
# =======

# Get a global property of ABCMAKE (with the ABCMAKE_PROPERTY_PREFIX)
# @param PROPERTY_NAME - The name of the property to get 
# @param OUT_VAR_NAME - The name of the variable to set with the result
# @param FALLBACK - Optional argument, if the property is not found, the value of FALLBACK will be used
function(_abcmake_get_prop PROPERTY_NAME OUT_VAR_NAME)
    # optional argument FALLBACK
    set(flags)
    set(args)
    set(listArgs FALLBACK)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    # Getting the property
    get_property(tmp_result GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME})
                 
    # If not found, try to use the fallback
    if(NOT tmp_result AND arg_FALLBACK)
        set(tmp_result ${arg_FALLBACK})
    endif()
    
    # Setting the result
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_abcmake_get_prop_dir DIRECTORY PROPERTY_NAME OUT_VAR_NAME)
    get_directory_property(tmp_result DIRECTORY ${DIRECTORY}
        ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

# Specific Getters
# =================

function(_abcmake_get_components OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_COMPONENTS_DIR} tmp_result 
                 FALLBACK ${_ABCMAKE_DEFAULT_COMPONENTS_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_abcmake_get_src OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_SRC_DIR} tmp_result  
                 FALLBACK ${_ABCMAKE_DEFAULT_SRC_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_abcmake_get_include OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_INCLUDE_DIR} tmp_result 
                 FALLBACK ${_ABCMAKE_DEFAULT_INCLUDE_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_abcmake_get_install OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_INSTALL_DIR} tmp_result 
                 FALLBACK ${_ABCMAKE_DEFAULT_INSTALL_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE) 
endfunction()

# abcmake_property.cmake =======================================================
# ==============================================================================


# ==============================================================================
# _abcmake_add_project.cmake ====================================================

# Add subdirectory to the project only if not added
function(_abcmake_add_subdirectory PATH)

    # ABCMAKE_ADDED_PROJECTS is an interface, it may break compatibility if changed!
    _abcmake_get_prop(${ABCMAKE_PROP_ADDED_PROJECTS} projects)
    
    # Resolve relative path
    get_filename_component(PATH "${PATH}" ABSOLUTE)
    
    if (NOT PATH IN_LIST projects)
        # Add PATH to the global list
        _abcmake_set_prop(${ABCMAKE_PROP_ADDED_PROJECTS} ${PATH})
        
        # Use the last directory name for a binary directory name 
        get_filename_component(last_dir "${PATH}" NAME)
        add_subdirectory(${PATH} abc_${last_dir})
    endif()
    
endfunction()

function(_abcmake_add_project PATH OUT_ABCMAKE_VER)
    if (EXISTS ${PATH}/CMakeLists.txt)
        message(DEBUG "Adding project ${PATH}")
        _abcmake_add_subdirectory(${PATH})
        
        _abcmake_get_prop_dir(${PATH} "VERSION" version)
        set(${OUT_ABCMAKE_VER} ${version} PARENT_SCOPE)
        if (NOT version)
            message (STATUS "  🔶 ${PATH} is not an ABCMAKE project. Link it manually.")
        endif()
        
    else()
        message (STATUS "  ⬜ ${PATH} is not a CMake project. Skipping...")
    endif()
endfunction()

# _abcmake_add_project.cmake ====================================================
# ==============================================================================


# ----------------------------------------------------------------------------
# Public Functions
# ----------------------------------------------------------------------------

# ==============================================================================
# add_component.cmake ==========================================================

include(CMakeParseArguments)
set(ABC_INSTALL_LIB_SUBDIR "lib")
set(ABC_INSTALL_EXE_SUBDIR ".")

# Add all projects from the components subdirectory
# @param TARGETNAME - name of the target to add components
function(_abcmake_add_components TARGETNAME)

    # Get component directory
    _abcmake_get_components(components)

    # List of possible subprojects
    file(GLOB children RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/${components} ${CMAKE_CURRENT_SOURCE_DIR}/${components}/*)
    
    # Link all subprojects to the ${TARGETNAME}
    foreach(child ${children})
        if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${components}/${child})
            target_link_component(${TARGETNAME} ${CMAKE_CURRENT_SOURCE_DIR}/${components}/${child})
        endif()
    endforeach()
    
endfunction()

# Add all source files from the specified directory to the target
# @param TARGETNAME - name of the target to add sources
function(target_sources_directory TARGETNAME SOURCE_DIR)
    file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.cpp" "${SOURCE_DIR}/*.c")
    message( DEBUG "${TARGETNAME} sources: ${SOURCES}")
    target_sources(${TARGETNAME} PRIVATE ${SOURCES})
endfunction()

# Install the target near the build directory
# @param TARGETNAME - name of the target to install
# @param DESTINATION - path to the destination directory inside the install dir
function(_abcmake_target_install TARGETNAME DESTINATION)
    # install directory
    _abcmake_get_install(install_dir)
    set (CMAKE_INSTALL_PREFIX ${install_dir}
         CACHE PATH "default install path" FORCE)
    install(TARGETS ${TARGETNAME} DESTINATION ${DESTINATION})
endfunction()


# Add to the project all files from ./src, ./include, ./lib
# @param TARGETNAME - name of the target to initialize
# @param INCLUDE_DIR - path to the include directory
# @param SOURCE_DIR - path to the source directory
function(_abcmake_target_init TARGETNAME)
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

    get_directory_property(hasParent PARENT_DIRECTORY)
    # if no parent, print the name of the target
    if (NOT hasParent)
        message(STATUS "🔤 ${TARGETNAME}")
    endif ()
    
    # Report version
    _abcmake_set_prop_curdir(${ABCMAKE_DIRPROP_VERSION} ${ABCMAKE_VERSION})
                 
    # Add target to the target list
    _abcmake_append_prop_curdir(${ABCMAKE_DIRPROP_TARGETS} ${TARGETNAME})
    
    foreach(s ${arg_SOURCE_DIR})
        target_sources_directory(${TARGETNAME} ${s})
    endforeach()
    
    target_include_directories(${TARGETNAME} PUBLIC ${arg_INCLUDE_DIR})
    _abcmake_add_components(${TARGETNAME})

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
        _abcmake_get_src(arg_SOURCE_DIR)
    endif()
    
    if (NOT arg_INCLUDE_DIR)
        _abcmake_get_include(arg_INCLUDE_DIR)
    endif()
    
    add_executable(${TARGETNAME})
    _abcmake_target_init(${TARGETNAME} 
                         INCLUDE_DIR ${arg_INCLUDE_DIR} 
                         SOURCE_DIR ${arg_SOURCE_DIR})
    _abcmake_target_install(${TARGETNAME} ${ABC_INSTALL_EXE_SUBDIR})
endfunction()

# Add a shared or static library component to the project
# @param TARGETNAME - name of the target to add the component
# @param INCLUDE_DIR - paths to the include directories
# @param SOURCE_DIR - paths to the source directories
# @param SHARED - if set to TRUE, the library will be shared
function(add_component TARGETNAME)
    set(flags SHARED)
    set(args)
    set(listArgs INCLUDE_DIR SOURCE_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    if (NOT arg_SOURCE_DIR)
        _abcmake_get_src(arg_SOURCE_DIR)
    endif()

    if (NOT arg_INCLUDE_DIR)
        _abcmake_get_include(arg_INCLUDE_DIR)
    endif()

    if (arg_SHARED)
        add_library(${TARGETNAME} SHARED)
    else()
        add_library(${TARGETNAME} STATIC)
    endif()
    
    _abcmake_target_init(${TARGETNAME} 
                         INCLUDE_DIR ${arg_INCLUDE_DIR} 
                         SOURCE_DIR ${arg_SOURCE_DIR})
    _abcmake_target_install(${TARGETNAME} ${ABC_INSTALL_LIB_SUBDIR})
endfunction()


# add_component.cmake ==========================================================
# ==============================================================================


# ==============================================================================
# component_register.cmake =====================================================


function(register_component COMPONENT_PATH)

endfunction()


# component_register.cmake =====================================================
# ==============================================================================



# ==============================================================================
# target_link_component.cmake ==================================================

# Link the component to the target
# DEPRECATED! Use target_link_components instead
#
# @param TARGETNAME - name of the target for linking
# @param COMPONENTPATH - path to the component to link
function (target_link_component TARGETNAME COMPONENTPATH)
    _abcmake_add_project(${COMPONENTPATH} ver)
    if (ver)
        _abcmake_get_prop_dir(${COMPONENTPATH} ${ABCMAKE_DIRPROP_TARGETS} to_link)
        message (STATUS "  ✅ Linking ${to_link} to ${TARGETNAME}")
        target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
    endif()
endfunction()

# Link components to the target
# @param TARGETNAME - name of the target for linking
# @param COMPONENT_DIR - path to the component to link
function (target_link_components TARGETNAME)
    set(flags)
    set(args)
    set(listArgs COMPONENT_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    foreach(COMPONENTPATH ${COMPONENT_DIR})
        target_link_component(${TARGETNAME} ${COMPONENTPATH})
    endforeach()
    
    foreach(COMPONENTPATH ${ARGN})
        target_link_component(${TARGETNAME} ${COMPONENTPATH})
    endforeach()
endfunction()

# target_link_component.cmake ==================================================
# ==============================================================================

