# ==============================================================================
# target_link_components.cmake =================================================

# Link a component to the target
#
# @param TARGETNAME - name of the target for linking
# @param COMPONENTPATH - path to the component to link
function (_abcmake_target_link_single_component PROCESS_LEVEL TARGETNAME COMPONENTPATH)

    _abcmake_add_project(${COMPONENTPATH} ver)
    if (ver)
        # What to link?
        _abcmake_get_prop_dir(${COMPONENTPATH} ${ABCMAKE_DIRPROP_TARGETS} to_link)
        
        # Link
        target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
        _abcmake_log_ok(${PROCESS_LEVEL} "${TARGETNAME}: linked ${to_link}")
    endif()
endfunction()



# Link components to the target
# @param PROCESS_LEVEL - level of the process in the call stack (for logging)
# @param TARGETNAME - name of the target for linking
# @param PATH - paths to components to link
# @param NAME - names of components to link
function (_abcmake_target_link_components PROCESS_LEVEL TARGETNAME)
    math(EXPR process_level "${PROCESS_LEVEL} + 1")
    
    set(flags)
    set(args)
    set(listArgs PATH NAME)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    message(DEBUG "[_abcmake_target_link_components] arg_PATH: ${arg_PATH}")
    message(DEBUG "[_abcmake_target_link_components] arg_NAME: ${arg_NAME}")
    
    # Link components by path
    foreach(PATH ${arg_PATH})
        _abcmake_target_link_single_component(${process_level} ${TARGETNAME} ${PATH})
    endforeach()
    
    # Link components by name
    foreach(NAME ${arg_NAME})
        set(reg_path "") # reset the variable
        _abcmake_get_from_registry(${NAME} reg_path)
        if (reg_path)
            message ( DEBUG "Found component: ${NAME} -> ${reg_path}")
            _abcmake_target_link_single_component(${process_level} ${TARGETNAME} ${reg_path})
        else()
            _abcmake_log_err(${process_level} "${NAME} not found in the component registry!")
            _abcmake_log(${process_level} "Use `register_components` to add it to the registry")
            message (FATAL_ERROR "Component ${NAME} not found in the registry")
        endif()
    endforeach()
    
    
endfunction()

# Link components to the target
# @param TARGETNAME - name of the target for linking
# @param PATH - paths to components to link
# @param NAME - names of components to link
function (target_link_components TARGETNAME)
    _abcmake_target_link_components(0 ${TARGETNAME} ${ARGN})
endfunction()

# target_link_components.cmake =================================================
# ==============================================================================
