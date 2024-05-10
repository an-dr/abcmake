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

include(${CMAKE_CURRENT_LIST_DIR}/version.cmake)

# Configure CMake
set(ABCMAKE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# ----------------------------------------------------------------------------
# Internal CMake modules
# ----------------------------------------------------------------------------

include(${CMAKE_CURRENT_LIST_DIR}/abcmake/_abcmake_log.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/abcmake/_abcmake_property.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/abcmake/_abcmake_add_project.cmake)

# ----------------------------------------------------------------------------
# Public Functions
# ----------------------------------------------------------------------------

include(${CMAKE_CURRENT_LIST_DIR}/abcmake/add_component.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/abcmake/register_components.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/abcmake/target_link_components.cmake)
