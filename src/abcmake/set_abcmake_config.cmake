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
    

    
endfunction()

# set_abcmake_config.cmake =====================================================
# ==============================================================================
