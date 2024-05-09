# ==============================================================================
# target_link_component.cmake ==================================================

# Link the component to the target
# DEPRECATED! Use target_link_components instead
#
# @param TARGETNAME - name of the target for linking
# @param COMPONENTPATH - path to the component to link
function (target_link_component TARGETNAME COMPONENTPATH)
    _abcmake_add_project(${COMPONENTPATH} ver)
    if (ver)
        _abcmake_get_prop_dir(${COMPONENTPATH} ${ABCMAKE_DIRPROP_TARGETS} to_link)
        message (STATUS "  ✅ Linking ${to_link} to ${TARGETNAME}")
        target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
    endif()
endfunction()

# Link components to the target
# @param TARGETNAME - name of the target for linking
# @param COMPONENT_DIR - paths to components to link
# @param COMPONENT_NAME - names of components to link
function (target_link_components TARGETNAME)
    set(flags)
    set(args)
    set(listArgs COMPONENT_DIR COMPONENT_NAME)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    message(STATUS "arg_COMPONENT_DIR = ${arg_COMPONENT_DIR}")
    message(STATUS "arg_COMPONENT_NAME = ${arg_COMPONENT_NAME}")
    
    foreach(COMPONENTPATH ${arg_COMPONENT_DIR})
        target_link_component(${TARGETNAME} ${COMPONENTPATH})
    endforeach()
    
    # foreach(COMPONENTPATH ${ARGN})
    #     target_link_component(${TARGETNAME} ${COMPONENTPATH})
    # endforeach()
    
    # Link components by name
    foreach(NAME ${arg_COMPONENT_NAME})
        _abcmake_get_from_registry(${NAME} COMPONENTPATH)
        if (COMPONENTPATH)
            target_link_component(${TARGETNAME} ${COMPONENTPATH})
        endif()
    endforeach()
endfunction()

# target_link_component.cmake ==================================================
# ==============================================================================
