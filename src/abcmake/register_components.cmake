# ==============================================================================
# register_components.cmake ====================================================

set(__ABCMAKE_COMPONENT_REGISTRY_SEPARATOR "::::")

# Register a component by adding it to the registry
# @param PATH - list of paths to the components
function(register_components PATH)

    foreach(path ${ARGV})
        message(DEBUG "[register_components] 📂 Path: ${path}")
        _abcmake_add_project(${path} PROJECT_ABCMAKE_VER)
        if(PROJECT_ABCMAKE_VER)
            _abcmake_get_prop_dir(${path} ${ABCMAKE_DIRPROP_COMPONENT_NAME} component_name)
            set(new_entry "${component_name}${__ABCMAKE_COMPONENT_REGISTRY_SEPARATOR}${path}")
            _abcmake_append_prop(${ABCMAKE_PROP_COMPONENT_REGISTRY} ${new_entry})
            
            _abcmake_log_header(0 "${component_name} (registered)")
        endif()
    endforeach()
    
endfunction()

# Splits into COMPONENT_ENTRY into COMPONENT_NAME and COMPONENT_PATH
function (_split_component_entry COMPONENT_ENTRY OUT_NAME OUT_PATH)
    string(FIND ${COMPONENT_ENTRY} ${__ABCMAKE_COMPONENT_REGISTRY_SEPARATOR} sep_pos)
    if(sep_pos EQUAL -1)
        message(FATAL_ERROR "Invalid component entry: ${COMPONENT_ENTRY}")
    endif()
    
    string(REGEX MATCH "^(.+)${__ABCMAKE_COMPONENT_REGISTRY_SEPARATOR}(.+)"
           ENTRY_MATCH ${COMPONENT_ENTRY})
    set(name ${CMAKE_MATCH_1})
    set(path ${CMAKE_MATCH_2})
    
    set(${OUT_NAME} ${name} PARENT_SCOPE)
    set(${OUT_PATH} ${path} PARENT_SCOPE)
endfunction()

# Gets the path of a component from the registry. Returns null if not found.
function (_abcmake_get_from_registry COMPONENT_NAME OUT_PATH)
    _abcmake_get_prop(${ABCMAKE_PROP_COMPONENT_REGISTRY} registry)
    message(DEBUG "[_abcmake_get_from_registry] Get ${COMPONENT_NAME} from : ${registry}")
    foreach(entry ${registry})
        _split_component_entry(${entry} name path)
        if(name STREQUAL COMPONENT_NAME)
            set(${OUT_PATH} ${path} PARENT_SCOPE)
            return()
        endif()
    endforeach()
endfunction()
    
# register_components.cmake ====================================================
# ==============================================================================


