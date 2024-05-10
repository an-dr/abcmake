# ==============================================================================
# _abcmake_log.cmake.cmake =====================================================

set(__ABCMAKE_INDENTATION "  ")

if ($ENV{ABCMAKE_EMOJI})
    set(__ABCMAKE_COMPONENT "🔤")
    set(__ABCMAKE_OK "✅")
    set(__ABCMAKE_ERROR "❌")
    set(__ABCMAKE_WARNING "🔶")
    set(__ABCMAKE_NOTE "⬜")
else()
    set(__ABCMAKE_COMPONENT "[ABCMAKE]")
    set(__ABCMAKE_OK        "[DONE]")
    set(__ABCMAKE_ERROR     "[ERROR]")
    set(__ABCMAKE_WARNING   "[WARNING]")
    set(__ABCMAKE_NOTE      "[INFO]")
endif()

# Print a message with indentation
# @param INDENTATION The indentation level. If < 0, the message is not printed
# @param MESSAGE The message to print
function(_abcmake_log INDENTATION MESSAGE)
    if(${INDENTATION} GREATER_EQUAL 0)
        string(REPEAT ${__ABCMAKE_INDENTATION} ${INDENTATION} indentation)
        message(STATUS "${indentation}${MESSAGE}")
    endif()
endfunction()

function(_abcmake_log_ok INDENTATION MESSAGE)
    _abcmake_log(${INDENTATION} "${__ABCMAKE_OK} ${MESSAGE}")
endfunction()

function(_abcmake_log_err INDENTATION MESSAGE)
    _abcmake_log(${INDENTATION} "${__ABCMAKE_ERROR} ${MESSAGE}")
endfunction()

function(_abcmake_log_warn INDENTATION MESSAGE)
    _abcmake_log(${INDENTATION} "${__ABCMAKE_WARNING} ${MESSAGE}")
endfunction()

function(_abcmake_log_note INDENTATION MESSAGE)
    _abcmake_log(${INDENTATION} "${__ABCMAKE_NOTE} ${MESSAGE}")
endfunction()

function(_abcmake_log_header INDENTATION MESSAGE)
    _abcmake_log(${INDENTATION} "${__ABCMAKE_COMPONENT} ${MESSAGE}")
endfunction()


# _abcmake_log.cmake.cmake =====================================================
# ==============================================================================
