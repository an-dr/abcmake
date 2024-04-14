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
# *************************************************************************

set(ABCMAKE TRUE)
set(ABCMAKE_VERSION_MAJOR 4)
set(ABCMAKE_VERSION_MINOR 0)
set(ABCMAKE_VERSION_PATCH 0)
set(ABCMAKE_VERSION "${ABCMAKE_VERSION_MAJOR}.${ABCMAKE_VERSION_MINOR}.${ABCMAKE_VERSION_PATCH}")

function(_abc_AddProject Path )
    add_subdirectory(${Path})
endfunction()

# Add all projects forom the lib subdirectory
function(_abc_AddLibs TargetName)
    file(GLOB children RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/lib ${CMAKE_CURRENT_SOURCE_DIR}/lib/*)
    foreach(child ${children})
        message(STATUS "📔 ${TargetName} found ${child}")
        if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lib/${child})
            _abc_AddProject(${CMAKE_CURRENT_SOURCE_DIR}/lib/${child})
        endif()
        target_link_libraries(${TargetName} child)
    endforeach()
endfunction()

# Add to the project all files from ./src, ./include, ./lib
function(target_abcmake TargetName)
    message(STATUS "📔 ABCMAKE: ${TargetName}")
    # files
    file(GLOB_RECURSE SOURCES "src/*.cpp" "src/*.c")
    message(STATUS "📔 ${TargetName} sources: ${SOURCES}")
    target_sources(${TargetName} PRIVATE ${SOURCES})
    message(STATUS "📔 ${TargetName} include: ${CMAKE_CURRENT_SOURCE_DIR}/include")
    target_include_directories(${TargetName} PUBLIC include)
    # install directory
    # if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/../install"
            CACHE PATH "default install path" FORCE)
    # endif()
    _abc_AddLibs(${TargetName})
    install(TARGETS ${TargetName} DESTINATION ".")
endfunction()
