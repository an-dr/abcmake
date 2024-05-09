# ==============================================================================
# target_link_components.cmake =================================================

# Link the component to the target
#
# @param TARGETNAME - name of the target for linking
# @param COMPONENTPATH - path to the component to link
function (_abcmake_target_link_component TARGETNAME COMPONENTPATH)
    _abcmake_add_project(${COMPONENTPATH} ver)
    if (ver)
        _abcmake_get_prop_dir(${COMPONENTPATH} ${ABCMAKE_DIRPROP_TARGETS} to_link)
        _abcmake_log_ok(1 "Linking to ${TARGETNAME}: ${to_link}")
        target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
    endif()
endfunction()

# Link components to the target
# @param TARGETNAME - name of the target for linking
# @param PATH - paths to components to link
# @param NAME - names of components to link
function (target_link_components TARGETNAME)
    set(flags)
    set(args)
    set(listArgs PATH NAME)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    message(DEBUG "target_link_components arg_PATH: ${arg_PATH}")
    message(DEBUG "target_link_components arg_NAME: ${arg_NAME}")
    
    # Link components by path
    foreach(PATH ${arg_PATH})
        _abcmake_target_link_component(${TARGETNAME} ${PATH})
    endforeach()
    
    # Link components by name
    foreach(NAME ${arg_NAME})
        _abcmake_get_from_registry(${NAME} reg_path)
        if (reg_path)
            message ( DEBUG "Found component: ${NAME} -> ${reg_path}")
            _abcmake_target_link_component(${TARGETNAME} ${reg_path})
        else()
            _abcmake_log_err(0 "Component ${NAME} not found in the registry")
            _abcmake_log(1 "Use `register_components` to add it to the registry")
            message (FATAL_ERROR "Component ${NAME} not found in the registry")
        endif()
    endforeach()
    
    
endfunction()

# target_link_components.cmake =================================================
# ==============================================================================
