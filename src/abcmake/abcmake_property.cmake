# ==============================================================================
# abcmake_property.cmake =======================================================

# List of the global abcmake properties:
# - ABCMAKE_COMPONENTS_DIR
# - ABCMAKE_SRC_DIR
# - ABCMAKE_INCLUDE_DIR
# - ABCMAKE_INSTALL_DIR

# Default prop values
# ===================

# A change in any of these variables will cause a breaking change in the API
set(ABCMAKE_PROPERTY_PREFIX "ABCMAKE_")
set(ABCMAKE_DEFAULT_COMPONENTS_DIR "components")
set(ABCMAKE_DEFAULT_SRC_DIR "src")
set(ABCMAKE_DEFAULT_INCLUDE_DIR "include")
set(ABCMAKE_DEFAULT_INSTALL_DIR "${CMAKE_BINARY_DIR}/../install")


# Setters
# =======

function(_set_abcprop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_append_abcprop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_set_abcprop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_directory_properties(PROPERTIES
                             ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_append_abcprop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} 
                 APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()


# Getters
# =======

# Get a global property of ABCMAKE (with the ABCMAKE_PROPERTY_PREFIX)
# @param PROPERTY_NAME - The name of the property to get 
# @param OUT_VAR_NAME - The name of the variable to set with the result
# @param FALLBACK - Optional argument, if the property is not found, the value of FALLBACK will be used
function(_get_abcprop PROPERTY_NAME OUT_VAR_NAME)
    # optional argument FALLBACK
    set(flags)
    set(args)
    set(listArgs FALLBACK)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    # Getting the property
    get_property(tmp_result GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME})
                 
    # If not found, try to use the fallback
    if(NOT tmp_result AND arg_FALLBACK)
        set(tmp_result ${arg_FALLBACK})
    endif()
    
    # Setting the result
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_get_abcprop_dir DIRECTORY PROPERTY_NAME OUT_VAR_NAME)
    get_directory_property(tmp_result DIRECTORY ${DIRECTORY}
        ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

# Specific Getters
# =================

function(_get_abc_components OUT_VAR_NAME)
    _get_abcprop("COMPONENTS_DIR" tmp_result 
                 FALLBACK ${ABCMAKE_DEFAULT_COMPONENTS_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_get_abc_src OUT_VAR_NAME)
    _get_abcprop("SRC_DIR" tmp_result  
                 FALLBACK ${ABCMAKE_DEFAULT_SRC_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_get_abc_include OUT_VAR_NAME)
    _get_abcprop("INCLUDE_DIR" tmp_result 
                 FALLBACK ${ABCMAKE_DEFAULT_INCLUDE_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_get_abc_install OUT_VAR_NAME)
    _get_abcprop("INSTALL_DIR" tmp_result 
                 FALLBACK ${ABCMAKE_DEFAULT_INSTALL_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE) 
endfunction()

# abcmake_property.cmake =======================================================
# ==============================================================================

