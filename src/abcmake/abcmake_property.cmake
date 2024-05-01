

function(_set_abc PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_append_abc PROPERTY_NAME PROPERTY_VALUE)
    set_property(GLOBAL APPEND PROPERTY 
                 ${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME} ${PROPERTY_VALUE})
endfunction()

function(_set_abc_dir PROPERTY_NAME PROPERTY_VALUE)
    
endfunction()


# function(_get_abc PROPERTY_NAME OUT_VAR_NAME)
#     set(${OUT_VAR_NAME} ${${ABCMAKE_PROPERTY_PREFIX}_${PROPERTY_NAME}} PARENT_SCOPE)
# endfunction()

