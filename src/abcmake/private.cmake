# Add subdirectory to the project only if not added
function(_add_subdirectory PATH)

    # ABCMAKE_ADDED_PROJECTS is an interface, it may break compatibility if changed!
    get_property(projects GLOBAL PROPERTY ABCMAKE_ADDED_PROJECTS)
    
    # Resolve relative path
    get_filename_component(PATH "${PATH}" ABSOLUTE)
    
    if (NOT PATH IN_LIST projects)
        # Add PATH to the global list
        set_property(GLOBAL APPEND PROPERTY ABCMAKE_ADDED_PROJECTS ${PATH})
        
        # Use the last directory name for a binary directory name 
        get_filename_component(last_dir "${PATH}" NAME)
        add_subdirectory(${PATH} abc_${last_dir})
    endif()
    
endfunction()


function(_abc_AddProject PATH OUT_ABCMAKE_VER)
    if (EXISTS ${PATH}/CMakeLists.txt)
        message(DEBUG "Adding project ${PATH}")
        _add_subdirectory(${PATH})
        
        get_directory_property(version DIRECTORY ${PATH} ABCMAKE_VERSION)
        set(${OUT_ABCMAKE_VER} ${version} PARENT_SCOPE)
        if (NOT version)
            message (STATUS "  🔶 ${PATH} is not an ABCMAKE project. Link it manually.")
        endif()
        
    else()
        message (STATUS "  ❌ ${PATH} is not a CMake project")
    endif()
endfunction()


# Add all projects from the components subdirectory
# @param TARGETNAME - name of the target to add components
function(_abc_AddComponents TARGETNAME)
    # List of possible subprojects
    file(GLOB children RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/components ${CMAKE_CURRENT_SOURCE_DIR}/components/*)
    
    # Link all subprojects to the ${TARGETNAME}
    foreach(child ${children})
        if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/components/${child})
            target_link_component(${TARGETNAME} ${CMAKE_CURRENT_SOURCE_DIR}/components/${child})
        endif()
    endforeach()
    
endfunction()


# Install the target near the build directory
# @param TARGETNAME - name of the target to install
# @param DESTINATION - path to the destination directory inside the install dir
function(_target_install_near_build TARGETNAME DESTINATION)
    # install directory
    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/../install"
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
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY 
                 ABCMAKE_VERSION ${ABCMAKE_VERSION})
                 
    # Add target to the target list
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} APPEND PROPERTY
                 ABCMAKE_TARGETS ${TARGETNAME})
        
    target_sources_directory(${TARGETNAME} ${SOURCE_DIR})
    target_include_directories(${TARGETNAME} PUBLIC ${INCLUDE_DIR})
    _abc_AddComponents(${TARGETNAME})

endfunction()
