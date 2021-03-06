# SETTINGS zone

get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${PROJECT_NAME})
set(CMAKE_CXX_STANDARD 14)
set(ABCMAKELISTS_VER 3)


# init vars:
unset(CURRENT_INCDIRS)
unset(CURRENT_SRCS)


# childs: ==============================================================================================================
foreach (child ${ABC_CHILDS})
    add_subdirectory(${child})
    if (${ABCMAKELISTS_VER})
        list(APPEND FROM_CHILDS_INCDIRS ${CHILD_INCDIRS})
        list(APPEND FROM_CHILDS_LIBS ${CHILD_LIBS})
    endif ()
endforeach (child)
# /childs ==============================================================================================================

# include and sources:==================================================================================================
if(ABC_USE_PROJECT_ROOT)
    list(APPEND CURRENT_INCDIRS ${CMAKE_CURRENT_SOURCE_DIR})
    aux_source_directory(. CURRENT_SRCS)
endif()
list(APPEND CURRENT_INCDIRS ${CMAKE_CURRENT_SOURCE_DIR}/include)
aux_source_directory(src CURRENT_SRCS)
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
message(STATUS "  PROJECT:  ${PROJECT_NAME}")
message(STATUS "  SUBPROJECTS:  ${CHILDS}")
message(STATUS "  =======================================")

if (CURRENT_INCDIRS)
    message(STATUS "    INCLUDE DIRS:   ${CURRENT_INCDIRS}")
endif ()

if (CURRENT_SRCS)
    message(STATUS "    SOURSES:        ${CURRENT_SRCS}")
endif ()

if (FROM_CHILDS_INCDIRS)
    message(STATUS "    Child Includes: ${FROM_CHILDS_INCDIRS}")
endif ()

if (FROM_CHILDS_LIBS)
    message(STATUS "    Child Libs: ${FROM_CHILDS_LIBS}")
endif ()

# /output ==============================================================================================================
if (CURRENT_SRCS)
    add_library(${PROJECT_NAME} ${CURRENT_SRCS})
    target_link_libraries(${PROJECT_NAME} ${FROM_CHILDS_LIBS})
    target_include_directories(${PROJECT_NAME} PUBLIC ${FROM_CHILDS_INCDIRS} ${CURRENT_INCDIRS})
endif ()

# install
## lib
if (CURRENT_SRCS)
    install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_lib/lib)
endif ()
## headers. collecting
foreach (header_dir ${CURRENT_INCDIRS})
    file(GLOB HEADERS LIST_DIRECTORIES true ${header_dir}/*.h)
    list(APPEND PROJ_HEADERS ${HEADERS})
endforeach (header_dir)

## headers. install
foreach (header ${PROJ_HEADERS})
    install(FILES ${header} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_lib/include)
endforeach (header)
## sources
foreach (src ${CURRENT_SRCS})
    install(FILES ${src} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_lib/src)
endforeach (src)
