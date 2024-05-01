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
set(ABCMAKE_VERSION_MINOR 2)
set(ABCMAKE_VERSION_PATCH 0)
set(ABCMAKE_VERSION "${ABCMAKE_VERSION_MAJOR}.${ABCMAKE_VERSION_MINOR}.${ABCMAKE_VERSION_PATCH}")


# Configure CMake
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# ----------------------------------------------------------------------------
# Internal CMake modules
# ----------------------------------------------------------------------------
set(ABC_COMPONENTS_DIR "components")
set(ABC_SRC_DIR "src")
set(ABC_INCLUDE_DIR "include")
set(ABC_INSTALL_DIR "${CMAKE_BINARY_DIR}/../install")
set(ABC_INSTALL_LIB_SUBDIR "lib")
set(ABC_INSTALL_EXE_SUBDIR ".")
set(ABCMAKE_PROPERTY_PREFIX "ABCMAKE")

# ==============================================================================
# abcmake_property.cmake =======================================================

# Setters
# =======

function(_set_abcprop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_append_abcprop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_set_abcprop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_directory_properties(PROPERTIES
                             ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_append_abcprop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} 
                 APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

# Getters
# =======

function(_get_abcprop PROPERTY_NAME OUT_VAR_NAME)
    get_property(tmp_result GLOBAL PROPERTY 
        ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_get_abcprop_dir DIRECTORY PROPERTY_NAME OUT_VAR_NAME)
    get_directory_property(tmp_result DIRECTORY ${DIRECTORY}
        ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

# abcmake_property.cmake =======================================================
# ==============================================================================



# ----------------------------------------------------------------------------
# Public Functions
# ----------------------------------------------------------------------------
# ==============================================================================
# set_abcmake_config.cmake =====================================================

function (set_abcmake_config)
    set(flags SHARED)
    set(args)
    set(listArgs COMPONENTS_DIR 
                 SRC_DIR
                 INCLUDE_DIR
                 INSTALL_DIR
                 INSTALL_LIB_SUBDIR
                 INSTALL_EXE_SUBDIR)
    cmake_parse_arguments(ABCMAKE "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    if (ABCMAKE_COMPONENTS_DIR)
        set(ABC_COMPONENTS_DIR ${ABCMAKE_COMPONENTS_DIR})
    endif()
    
    if (ABCMAKE_SRC_DIR)
        set(ABC_SRC_DIR ${ABCMAKE_SRC_DIR})
    endif()
    
    if (ABCMAKE_INCLUDE_DIR)
        set(ABC_INCLUDE_DIR ${ABCMAKE_INCLUDE_DIR})
    endif()
    
    if (ABCMAKE_INSTALL_DIR)
        set(ABC_INSTALL_DIR ${ABCMAKE_INSTALL_DIR})
    endif()
    
    if (ABCMAKE_INSTALL_LIB_SUBDIR)
        set(ABC_INSTALL_LIB_SUBDIR ${ABCMAKE_INSTALL_LIB_SUBDIR})
    endif()
    
    if (ABCMAKE_INSTALL_EXE_SUBDIR)
        set(ABC_INSTALL_EXE_SUBDIR ${ABCMAKE_INSTALL_EXE_SUBDIR})
    endif()
    
endfunction()

# set_abcmake_config.cmake =====================================================
# ==============================================================================

# ==============================================================================
# add_component.cmake ==========================================================

include(CMakeParseArguments)

# Add all projects from the components subdirectory
# @param TARGETNAME - name of the target to add components
function(_abc_AddComponents TARGETNAME)
    # List of possible subprojects
    file(GLOB children RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/${ABC_COMPONENTS_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/${ABC_COMPONENTS_DIR}/*)
    
    # Link all subprojects to the ${TARGETNAME}
    foreach(child ${children})
        if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ABC_COMPONENTS_DIR}/${child})
            target_link_component(${TARGETNAME} ${CMAKE_CURRENT_SOURCE_DIR}/${ABC_COMPONENTS_DIR}/${child})
        endif()
    endforeach()
    
endfunction()


# Install the target near the build directory
# @param TARGETNAME - name of the target to install
# @param DESTINATION - path to the destination directory inside the install dir
function(_target_install TARGETNAME DESTINATION)
    # install directory
    set (CMAKE_INSTALL_PREFIX ${ABC_INSTALL_DIR}
         CACHE PATH "default install path" FORCE)
    install(TARGETS ${TARGETNAME} DESTINATION ${DESTINATION})
endfunction()


# Add to the project all files from ./src, ./include, ./lib
# @param TARGETNAME - name of the target to initialize
# @param INCLUDE_DIR - path to the include directory
# @param SOURCE_DIR - path to the source directory
function(_target_init_abcmake TARGETNAME INCLUDE_DIR SOURCE_DIR)

    get_directory_property(hasParent PARENT_DIRECTORY)
    # if no parent, print the name of the target
    if (NOT hasParent)
        message(STATUS "🔤 ${TARGETNAME}")
    endif ()
    
    # Report version
    _set_abcprop_curdir("VERSION" ${ABCMAKE_VERSION})
                 
    # Add target to the target list
    _append_abcprop_curdir("TARGETS" ${TARGETNAME})
        
    target_sources_directory(${TARGETNAME} ${SOURCE_DIR})
    target_include_directories(${TARGETNAME} PUBLIC ${INCLUDE_DIR})
    _abc_AddComponents(${TARGETNAME})

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
        set(arg_SOURCE_DIR ${ABC_SRC_DIR})
    endif()
    
    if (NOT arg_INCLUDE_DIR)
        set(arg_INCLUDE_DIR ${ABC_INCLUDE_DIR})
    endif()
    
    add_executable(${TARGETNAME})
    _target_init_abcmake(${TARGETNAME} ${arg_INCLUDE_DIR} ${arg_SOURCE_DIR})
    _target_install(${TARGETNAME} ${ABC_INSTALL_EXE_SUBDIR})
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
        set(arg_SOURCE_DIR ${ABC_SRC_DIR})
    endif()

    if (NOT arg_INCLUDE_DIR)
        set(arg_INCLUDE_DIR ${ABC_INCLUDE_DIR})
    endif()

    if (arg_SHARED)
        add_library(${TARGETNAME} SHARED)
    else()
        add_library(${TARGETNAME} STATIC)
    endif()
    
    _target_init_abcmake(${TARGETNAME} ${arg_INCLUDE_DIR} ${arg_SOURCE_DIR})
    _target_install(${TARGETNAME} ${ABC_INSTALL_LIB_SUBDIR})
endfunction()


# add_component.cmake ==========================================================
# ==============================================================================

# ==============================================================================
# target_sources_directory.cmake ===============================================

# Add all source files from the specified directory to the target
# @param TARGETNAME - name of the target to add sources
function(target_sources_directory TARGETNAME SOURCE_DIR)
    file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.cpp" "${SOURCE_DIR}/*.c")
    message( DEBUG "${TARGETNAME} sources: ${SOURCES}")
    target_sources(${TARGETNAME} PRIVATE ${SOURCES})
endfunction()

# target_sources_directory.cmake ===============================================
# ==============================================================================

# ==============================================================================
# target_link_component.cmake ==================================================

# Add subdirectory to the project only if not added
function(_add_subdirectory PATH)

    # ABCMAKE_ADDED_PROJECTS is an interface, it may break compatibility if changed!
    _get_abcprop("ADDED_PROJECTS" projects)
    
    # Resolve relative path
    get_filename_component(PATH "${PATH}" ABSOLUTE)
    
    if (NOT PATH IN_LIST projects)
        # Add PATH to the global list
        _set_abcprop("ADDED_PROJECTS" ${PATH})
        
        # Use the last directory name for a binary directory name 
        get_filename_component(last_dir "${PATH}" NAME)
        add_subdirectory(${PATH} abc_${last_dir})
    endif()
    
endfunction()

function(_abc_AddProject PATH OUT_ABCMAKE_VER)
    if (EXISTS ${PATH}/CMakeLists.txt)
        message(DEBUG "Adding project ${PATH}")
        _add_subdirectory(${PATH})
        
        _get_abcprop_dir(${PATH} "VERSION" version)
        set(${OUT_ABCMAKE_VER} ${version} PARENT_SCOPE)
        if (NOT version)
            message (STATUS "  🔶 ${PATH} is not an ABCMAKE project. Link it manually.")
        endif()
        
    else()
        message (STATUS "  ❌ ${PATH} is not a CMake project")
    endif()
endfunction()

# Link the component to the target
# @param TARGETNAME - name of the target for linking
# @param COMPONENTPATH - path to the component to link
function (target_link_component TARGETNAME COMPONENTPATH)
    _abc_AddProject(${COMPONENTPATH} ver)
    if (ver)
        _get_abcprop_dir(${COMPONENTPATH} "TARGETS" to_link)
        message (STATUS "  ✅ Linking ${to_link} to ${TARGETNAME}")
        target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
    endif()
endfunction()

# target_link_component.cmake ==================================================
# ==============================================================================

