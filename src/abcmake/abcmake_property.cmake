# ==============================================================================
# abcmake_property.cmake =======================================================

# Setters
# =======

function(_set_abcprop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_append_abcprop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_set_abcprop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_directory_properties(PROPERTIES
                             ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_append_abcprop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} 
                 APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

# Getters
# =======

function(_get_abcprop PROPERTY_NAME OUT_VAR_NAME)
    get_property(tmp_result GLOBAL PROPERTY 
        ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_get_abcprop_dir DIRECTORY PROPERTY_NAME OUT_VAR_NAME)
    get_directory_property(tmp_result DIRECTORY ${DIRECTORY}
        ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

# abcmake_property.cmake =======================================================
# ==============================================================================

