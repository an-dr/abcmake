# ==============================================================================
# _abcmake_add_project.cmake ====================================================

# Add subdirectory to the project only if not added
function(_abcmake_add_subdirectory PATH)

    # ABCMAKE_ADDED_PROJECTS is an interface, it may break compatibility if changed!
    _abcmake_get_prop(${ABCMAKE_PROP_ADDED_PROJECTS} projects)
    message(DEBUG "Added projects: ${projects}")
    
    # Resolve relative path
    get_filename_component(PATH "${PATH}" ABSOLUTE)
    
    if (NOT PATH IN_LIST projects)
        # Add PATH to the global list
        _abcmake_append_prop(${ABCMAKE_PROP_ADDED_PROJECTS} ${PATH})
        
        # Use the last directory name for a binary directory name 
        get_filename_component(last_dir "${PATH}" NAME)
        add_subdirectory(${PATH} abc_${last_dir})
    endif()
    
endfunction()

function(_abcmake_add_project PATH OUT_ABCMAKE_VER)
    if (NOT EXISTS ${PATH})
        _abcmake_log_err(1 "Path \"${PATH}\" does not exist!")
        return()
    endif()
    
    if (NOT EXISTS ${PATH}/CMakeLists.txt)
        _abcmake_log_note(1 "No CMakeLists.txt: ${PATH}. Skipping...")
        return()
    endif()

    message(DEBUG "Adding project ${PATH}")
    _abcmake_add_subdirectory(${PATH})
    
    _abcmake_get_prop_dir(${PATH} "VERSION" version)
    set(${OUT_ABCMAKE_VER} ${version} PARENT_SCOPE)
    if (NOT version)
        _abcmake_log_warn(1 "Not abcmake: ${PATH}. Link it manually.")
    endif()
endfunction()

# _abcmake_add_project.cmake ====================================================
# ==============================================================================
