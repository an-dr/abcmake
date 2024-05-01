# ==============================================================================
# set_abcmake_config.cmake =====================================================

function (set_abcmake_config)
    set(flags SHARED)
    set(args)
    set(listArgs COMPONENTS_DIR 
                 SRC_DIR
                 INCLUDE_DIR
                 INSTALL_DIR
                 INSTALL_LIB_SUBDIR
                 INSTALL_EXE_SUBDIR)
    cmake_parse_arguments(ABCMAKE "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    if (ABCMAKE_COMPONENTS_DIR)
        set(ABC_COMPONENTS_DIR ${ABCMAKE_COMPONENTS_DIR})
    endif()
    
    if (ABCMAKE_SRC_DIR)
        set(ABC_SRC_DIR ${ABCMAKE_SRC_DIR})
    endif()
    
    if (ABCMAKE_INCLUDE_DIR)
        set(ABC_INCLUDE_DIR ${ABCMAKE_INCLUDE_DIR})
    endif()
    
    if (ABCMAKE_INSTALL_DIR)
        set(ABC_INSTALL_DIR ${ABCMAKE_INSTALL_DIR})
    endif()
    
    if (ABCMAKE_INSTALL_LIB_SUBDIR)
        set(ABC_INSTALL_LIB_SUBDIR ${ABCMAKE_INSTALL_LIB_SUBDIR})
    endif()
    
    if (ABCMAKE_INSTALL_EXE_SUBDIR)
        set(ABC_INSTALL_EXE_SUBDIR ${ABCMAKE_INSTALL_EXE_SUBDIR})
    endif()
    
endfunction()

# set_abcmake_config.cmake =====================================================
# ==============================================================================
