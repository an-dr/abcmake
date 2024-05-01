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
