cmake_minimum_required(VERSION 3.15)

include(${CMAKE_CURRENT_LIST_DIR}/src/version.cmake)
project(abcmake VERSION ${ABCMAKE_VERSION} LANGUAGES NONE)


# GNUInstallDirs for standard installation directories
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Installation paths
set(ABCMAKE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_DATADIR}/cmake/abcmake"
    CACHE STRING "Installation directory for cmake files")

# Install the cmake files with directory structure preserved
# Install root files
install(FILES
    src/ab.cmake
    src/version.cmake
    DESTINATION ${ABCMAKE_INSTALL_CMAKEDIR}
)

# Install abcmake subdirectory files
install(FILES
    src/abcmake/_abcmake_log.cmake
    src/abcmake/_abcmake_property.cmake
    src/abcmake/_abcmake_add_project.cmake
    src/abcmake/add_component.cmake
    src/abcmake/register_components.cmake
    src/abcmake/target_link_components.cmake
    DESTINATION ${ABCMAKE_INSTALL_CMAKEDIR}/abcmake
)

# Generate the config file that includes all the exports
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/abcmakeConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/abcmakeConfig.cmake"
    INSTALL_DESTINATION ${ABCMAKE_INSTALL_CMAKEDIR}
    PATH_VARS ABCMAKE_INSTALL_CMAKEDIR
)

# Generate the version file for the config file
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/abcmakeConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Install the generated config files
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/abcmakeConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/abcmakeConfigVersion.cmake"
    DESTINATION ${ABCMAKE_INSTALL_CMAKEDIR}
)

# Display installation information
message(STATUS "abcmake version ${PROJECT_VERSION}")
message(STATUS "Install destination: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "CMake files will be installed to: ${CMAKE_INSTALL_PREFIX}/${ABCMAKE_INSTALL_CMAKEDIR}")
