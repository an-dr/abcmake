# ==============================================================================
# target_link_components.cmake =================================================

# Link internal abcmake component if present.
# Returns TRUE in OUT_LINKED if a link action happened.
function(_abcmake_try_link_abcmake_component PROCESS_LEVEL TARGETNAME COMPONENTPATH OUT_LINKED)
    set(${OUT_LINKED} FALSE PARENT_SCOPE)
    _abcmake_add_project(${COMPONENTPATH} ver)
    if (ver)
        _abcmake_get_prop_dir(${COMPONENTPATH} ${ABCMAKE_DIRPROP_TARGETS} to_link)
        if (to_link)
            target_link_libraries(${TARGETNAME} PRIVATE ${to_link})
            _abcmake_log_ok(${PROCESS_LEVEL} "${TARGETNAME}: linked ${to_link}")
            set(${OUT_LINKED} TRUE PARENT_SCOPE)
        endif()
    endif()
endfunction()

# Attempt to detect and link CMake package(s) located in COMPONENTPATH.
# A package is detected by presence of *Config.cmake files.
# Returns TRUE in OUT_LINKED if any package targets were linked.
function(_abcmake_try_link_cmake_package PROCESS_LEVEL TARGETNAME COMPONENTPATH OUT_LINKED)
    set(linked FALSE)
    if (EXISTS ${COMPONENTPATH})
        file(GLOB _abc_pkg_configs "${COMPONENTPATH}/*Config.cmake")
        foreach(_abc_pkg_cfg ${_abc_pkg_configs})
            get_filename_component(_abc_pkg_cfg_name "${_abc_pkg_cfg}" NAME_WE)
            string(REGEX REPLACE "Config$" "" _abc_pkg_name "${_abc_pkg_cfg_name}")
            if (NOT _abc_pkg_name)
                continue()
            endif()
            find_package(${_abc_pkg_name} CONFIG PATHS "${COMPONENTPATH}" NO_DEFAULT_PATH QUIET)
            if (TARGET ${_abc_pkg_name}::${_abc_pkg_name})
                target_link_libraries(${TARGETNAME} PRIVATE ${_abc_pkg_name}::${_abc_pkg_name})
                _abcmake_log_ok(${PROCESS_LEVEL} "${TARGETNAME}: linked package ${_abc_pkg_name}::${_abc_pkg_name}")
                set(linked TRUE)
            elseif (TARGET ${_abc_pkg_name})
                target_link_libraries(${TARGETNAME} PRIVATE ${_abc_pkg_name})
                _abcmake_log_ok(${PROCESS_LEVEL} "${TARGETNAME}: linked package target ${_abc_pkg_name}")
                set(linked TRUE)
            else()
                _abcmake_log_warn(${PROCESS_LEVEL} "Detected package config for ${_abc_pkg_name} but no target ${_abc_pkg_name} or ${_abc_pkg_name}::${_abc_pkg_name} was created")
            endif()
        endforeach()
    endif()
    set(${OUT_LINKED} ${linked} PARENT_SCOPE)
endfunction()

# High-level helper to link a component (abcmake or package).
function (_abcmake_target_link_single_component PROCESS_LEVEL TARGETNAME COMPONENTPATH)
    _abcmake_try_link_abcmake_component(${PROCESS_LEVEL} ${TARGETNAME} ${COMPONENTPATH} linked_component)
    if (NOT linked_component)
        _abcmake_try_link_cmake_package(${PROCESS_LEVEL} ${TARGETNAME} ${COMPONENTPATH} linked_pkg)
        if (NOT linked_pkg)
            # Nothing linked: silent; original behavior simply warned for abcmake absence.
            # Keep a gentle note at higher verbosity if desired later.
        endif()
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
