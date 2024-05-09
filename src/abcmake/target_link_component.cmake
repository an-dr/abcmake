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
        _get_abcprop_dir(${COMPONENTPATH} "TARGETS" to_link)
        message (STATUS "  ✅ Linking ${to_link} to ${TARGETNAME}")
        target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
    endif()
endfunction()

# Link components to the target
# @param TARGETNAME - name of the target for linking
# @param COMPONENT_DIR - path to the component to link
function (target_link_components TARGETNAME)
    set(flags)
    set(args)
    set(listArgs COMPONENT_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    foreach(COMPONENTPATH ${COMPONENT_DIR})
        target_link_component(${TARGETNAME} ${COMPONENTPATH})
    endforeach()
    
    foreach(COMPONENTPATH ${ARGN})
        target_link_component(${TARGETNAME} ${COMPONENTPATH})
    endforeach()
endfunction()

# target_link_component.cmake ==================================================
# ==============================================================================
