# *************************************************************************
#
# Copyright (c) 2025 Andrei Gramakov. All rights reserved.
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

include("${CMAKE_CURRENT_LIST_DIR}/version.cmake")

set(PACKAGE_VERSION "${ABCMAKE_VERSION}")

# basic compatibility: same major, >= requested
if(PACKAGE_FIND_VERSION)
  if(ABCMAKE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
  else()
    string(REGEX MATCH "^([0-9]+)" _major "${ABCMAKE_VERSION}")
    set(_this_major "${CMAKE_MATCH_1}")
    string(REGEX MATCH "^([0-9]+)" _req_major "${PACKAGE_FIND_VERSION}")
    if(_this_major STREQUAL _req_major)
      set(PACKAGE_VERSION_COMPATIBLE TRUE)
      if(ABCMAKE_VERSION VERSION_EQUAL PACKAGE_FIND_VERSION)
        set(PACKAGE_VERSION_EXACT TRUE)
      endif()
    else()
      set(PACKAGE_VERSION_COMPATIBLE FALSE)
    endif()
  endif()
else()
  set(PACKAGE_VERSION_COMPATIBLE TRUE)
endif()
