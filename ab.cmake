# SETTINGS zone

get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${PROJECT_NAME})
set(CMAKE_CXX_STANDARD 14)
set(ABCMAKELISTS_VER 3)


# init vars:
unset(CURRENT_INCDIRS)
unset(CURRENT_SRCS)


# childs: ==============================================================================================================
foreach (child ${CHILDS})
    add_subdirectory(${child})
    if (${ABCMAKELISTS_VER})
        list(APPEND FROM_CHILDS_INCDIRS ${CHILD_INCDIRS})
        list(APPEND FROM_CHILDS_LIBS ${CHILD_LIBS})
    endif ()
endforeach (child)
# /childs ==============================================================================================================

# include and sources:==================================================================================================
list(APPEND CURRENT_INCDIRS ${CMAKE_CURRENT_SOURCE_DIR})
aux_source_directory(. CURRENT_SRCS)
list(FILTER CURRENT_SRCS EXCLUDE REGEX ".*main.cpp$")
list(FILTER CURRENT_SRCS EXCLUDE REGEX ".*main.c$")
# /include and sources =================================================================================================


# exports ==============================================================================================================
get_directory_property(hasParent PARENT_DIRECTORY)
if (hasParent)
    set(CHILD_INCDIRS ${CURRENT_INCDIRS} PARENT_SCOPE)
    set(CHILD_LIBS ${PROJECT_NAME} PARENT_SCOPE)
endif ()
# /exports =============================================================================================================


# output ===============================================================================================================
message(STATUS "  PROJECT:  ${PROJECT_NAME} is loaded")
message(STATUS "  SUBPROJECTS:  ${CHILDS}")
message(STATUS "  =======================================")

if (CURRENT_INCDIRS)
    message(STATUS "    INCLUDE DIRS:   ${CURRENT_INCDIRS}")
endif ()

if (CURRENT_SRCS)
    message(STATUS "    SOURSES:        ${CURRENT_SRCS}")
endif ()

message(STATUS "    Child Includes: ${FROM_CHILDS_INCDIRS}")
message(STATUS "    Child Libs: ${FROM_CHILDS_LIBS}")

# /output ==============================================================================================================
add_library(${PROJECT_NAME} ${CURRENT_SRCS})
target_link_libraries(${PROJECT_NAME} ${FROM_CHILDS_LIBS})
target_include_directories(${PROJECT_NAME} PUBLIC ${FROM_CHILDS_INCDIRS} ${CURRENT_INCDIRS})

# install
file(GLOB PROJ_HEADERS LIST_DIRECTORIES false ${FROM_CHILDS_INCDIRS} ${CURRENT_INCDIRS} *.h)
install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_lib/lib)
foreach (header ${PROJ_HEADERS})
    install(FILES ${header} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_lib/include)
endforeach (header)