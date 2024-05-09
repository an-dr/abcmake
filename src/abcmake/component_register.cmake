# ==============================================================================
# component_register.cmake =====================================================

set(__ABCMAKE_COMPONENT_REGISTRY_SEPARATOR "::::")

function(register_component COMPONENT_PATH)
    _abcmake_add_project(${COMPONENT_PATH} PROJECT_ABCMAKE_VER)
    if(PROJECT_ABCMAKE_VER)
        _abcmake_get_prop_dir(${COMPONENT_PATH} ${ABCMAKE_DIRPROP_COMPONENT_NAME} component_name)
        set(new_entry "${component_name}${__ABCMAKE_COMPONENT_REGISTRY_SEPARATOR}${COMPONENT_PATH}")
        
        _abcmake_append_prop(${ABCMAKE_PROP_COMPONENT_REGISTRY} ${new_entry})
        message(STATUS "Component registered: ${component_name}")
    endif()
endfunction()

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

function (_abcmake_get_from_registry COMPONENT_NAME OUT_PATH)
    _abcmake_get_prop(${ABCMAKE_PROP_COMPONENT_REGISTRY} registry)
    foreach(entry ${registry})
        _split_component_entry(${entry} name path)
        if(name STREQUAL COMPONENT_NAME)
            set(${OUT_PATH} ${path} PARENT_SCOPE)
            return()
        endif()
    endforeach()
endfunction()
    
# component_register.cmake =====================================================
# ==============================================================================


