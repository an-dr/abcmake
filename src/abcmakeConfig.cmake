
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was abcmakeConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

# abcmake Package Configuration File
#
# This file sets up the abcmake build system for use in other projects.
# After installation, use it with:
#   find_package(abcmake REQUIRED)

# Compute the installation prefix relative to this file
get_filename_component(ABCMAKE_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

# Set ABCMAKE_PATH to the installation directory
set(ABCMAKE_PATH "${ABCMAKE_CMAKE_DIR}")

# Make abcmake functions available
include("${ABCMAKE_CMAKE_DIR}/ab.cmake")

check_required_components(abcmake)

# Provide helpful variables for users
set(abcmake_FOUND TRUE)
set(abcmake_VERSION "${ABCMAKE_VERSION}")
set(abcmake_DIR "${ABCMAKE_CMAKE_DIR}")

message(STATUS "Found abcmake: ${abcmake_VERSION} (${ABCMAKE_CMAKE_DIR})")
