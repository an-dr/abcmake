# ==============================================================================
# abcmake_property.cmake =======================================================

# A change in any of these variables will cause a breaking change in the API!

set(ABCMAKE_PROPERTY_PREFIX "ABCMAKE_")

# Global properties:
set(ABCMAKE_PROP_ADDED_PROJECTS "ADDED_PROJECTS") # The list of projects that have been added to the solution
set(ABCMAKE_PROP_COMPONENT_REGISTRY "COPONENT_REGISTRY") # Component registry
set(_ABCMAKE_PROP_COMPONENTS_DIR "COMPONENTS_DIR") # The directory where the components are stored
set(_ABCMAKE_PROP_SRC_DIR "SRC_DIR") # The directory where the source files are stored
set(_ABCMAKE_PROP_INCLUDE_DIR "INCLUDE_DIR") # The directory where the include files are stored
set(_ABCMAKE_PROP_INSTALL_DIR "INSTALL_DIR") # The directory where the project will be installed

# Directory-scope properties
set(ABCMAKE_DIRPROP_VERSION "VERSION") # The abcmake version of the component
set(ABCMAKE_DIRPROP_COMPONENT_NAME "COMPONENT_NAME") # The name of the component (local PROJECT_NAME)
set(ABCMAKE_DIRPROP_TARGETS "TARGETS") # The list of targets built by the component

# Default values
set(_ABCMAKE_DEFAULT_COMPONENTS_DIR "components")
set(_ABCMAKE_DEFAULT_SRC_DIR "src")
set(_ABCMAKE_DEFAULT_INCLUDE_DIR "include")
set(_ABCMAKE_DEFAULT_INSTALL_DIR "${CMAKE_BINARY_DIR}/../install")


# Setters
# =======

function(_abcmake_set_prop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_abcmake_append_prop PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_abcmake_set_prop_curdir PROPERTY_NAME PROPERTY_VALUE)
    set_directory_properties(PROPERTIES
                             ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_abcmake_append_prop_curdir PROPERTY_NAME PROPERTY_VALUE)
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
function(_abcmake_get_prop PROPERTY_NAME OUT_VAR_NAME)
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

function(_abcmake_get_prop_dir DIRECTORY PROPERTY_NAME OUT_VAR_NAME)
    get_directory_property(tmp_result DIRECTORY ${DIRECTORY}
        ${ABCMAKE_PROPERTY_PREFIX}${PROPERTY_NAME})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

# Specific Getters
# =================

function(_abcmake_get_components OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_COMPONENTS_DIR} tmp_result 
                 FALLBACK ${_ABCMAKE_DEFAULT_COMPONENTS_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_abcmake_get_src OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_SRC_DIR} tmp_result  
                 FALLBACK ${_ABCMAKE_DEFAULT_SRC_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_abcmake_get_include OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_INCLUDE_DIR} tmp_result 
                 FALLBACK ${_ABCMAKE_DEFAULT_INCLUDE_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE)
endfunction()

function(_abcmake_get_install OUT_VAR_NAME)
    _abcmake_get_prop(${_ABCMAKE_PROP_INSTALL_DIR} tmp_result 
                 FALLBACK ${_ABCMAKE_DEFAULT_INSTALL_DIR})
    set(${OUT_VAR_NAME} ${tmp_result} PARENT_SCOPE) 
endfunction()

# abcmake_property.cmake =======================================================
# ==============================================================================

