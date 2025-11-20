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
    src/abcmakeConfig.cmake
    src/abcmakeConfigVersion.cmake
    src/version.cmake
    DESTINATION ${ABCMAKE_INSTALL_CMAKEDIR}
)

install(FILES
    src/abcmake/_abcmake_add_project.cmake
    src/abcmake/_abcmake_log.cmake
    src/abcmake/_abcmake_property.cmake
    src/abcmake/add_component.cmake
    src/abcmake/register_components.cmake
    src/abcmake/target_link_components.cmake
    DESTINATION ${ABCMAKE_INSTALL_CMAKEDIR}/abcmake
)


# Copy installer and docs to package root (CMAKE_INSTALL_PREFIX)
install(CODE "
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/LICENSE 
         DESTINATION \"\${CMAKE_INSTALL_PREFIX}\")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/README.md 
         DESTINATION \"\${CMAKE_INSTALL_PREFIX}\")
    
    message(STATUS \"Package root files installed to: \${CMAKE_INSTALL_PREFIX}\")
")

# Display installation information
message(STATUS "abcmake version ${PROJECT_VERSION}")
message(STATUS "Install destination: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "CMake files will be installed to: ${CMAKE_INSTALL_PREFIX}/${ABCMAKE_INSTALL_CMAKEDIR}")
