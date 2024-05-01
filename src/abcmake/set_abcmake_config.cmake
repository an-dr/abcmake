# ==============================================================================
# set_abcmake_project_structure.cmake ==========================================

# Configures the project structure for the project and subprojects.
# @param COMPONENTS_DIR: Optional. The directory where the components are stored.
# @param SRC_DIR: Optional. The directory where the source files are stored.
# @param INCLUDE_DIR: Optional. The directory where the include files are stored.
# @param INSTALL_DIR: Optional. The directory where the project is installed.
function (set_abcmake_project_structure)
    set(flags SHARED)
    set(args)
    set(listArgs COMPONENTS_DIR 
                 SRC_DIR
                 INCLUDE_DIR
                 INSTALL_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    if (arg_COMPONENTS_DIR)
        _set_abcprop(COMPONENTS_DIR ${arg_COMPONENTS_DIR})
    endif()
    
    if (arg_SRC_DIR)
        _set_abcprop(SRC_DIR ${arg_SRC_DIR})
    endif()
    
    if (arg_INCLUDE_DIR)
        _set_abcprop(INCLUDE_DIR ${arg_INCLUDE_DIR})
    endif()
    
    if (arg_INSTALL_DIR)
        _set_abcprop(INSTALL_DIR ${arg_INSTALL_DIR})
    endif()
    
    _get_abc_components("current_components")
    _get_abc_src("current_src")
    _get_abc_include("current_include")
    _get_abc_install("current_install")
    message(STATUS "🔤 New project structure applied")
    message(STATUS "  📁 Components: ${current_components}")
    message(STATUS "  📁 Sources: ${current_src}")
    message(STATUS "  📁 Include: ${current_include}")
    message(STATUS "  📁 Install: ${current_install}")
    
endfunction()

# set_abcmake_project_structure.cmake ==========================================
# ==============================================================================
