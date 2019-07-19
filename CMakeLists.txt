# Will be exported for parrent using:
#       ${PROJECT_NAME}_INCDIRS folders
#       ${PROJECT_NAME}_SRC folders
# You could add childs subfolder with the same CMakeLists.txt at Settings zone

# ======================================================================================================================

# SETTINGS zone

set(PROJECT_NAME THENAME)
set(PROJECT_INCLUDES) # folders
set(PROJECT_SRC) # files
set(MAIN_SRC main.cpp) # Main

set(CHILDS) # folders


cmake_minimum_required(VERSION 3.0)
set(CMAKE_CXX_STANDARD 14)
project(${PROJECT_NAME} LANGUAGES CXX)


# childs ===============================================================================================================
set(CHILDS_INCLUDEDIRS)
set(CHILDS_SRCS)
foreach (child ${CHILDS})
    add_subdirectory(${child})
    set(CHILDS_INCDIRS ${CHILDS_INCDIRS} ${${child}_INCDIRS})
    set(CHILDS_SRCS ${CHILDS_SRCS} ${${child}_SRCS})
endforeach (child)
# /childs ==============================================================================================================


# exports ==============================================================================================================
get_directory_property(hasParent PARENT_DIRECTORY)
if(hasParent)
    foreach (inc_dir ${PROJECT_INCDIRS})
        set(${PROJECT_NAME}_INCDIRS \${${PROJECT_NAME}_INCDIRS} ${CMAKE_CURRENT_SOURCE_DIR}/${inc_dir})
    endforeach (inc_dir)

    foreach (src ${PROJECT_SRCS})
        set(${PROJECT_NAME}_SRCS \${${PROJECT_NAME}_SRCS} ${CMAKE_CURRENT_SOURCE_DIR}/${src})
    endforeach (src)

    set(${PROJECT_NAME}_INCDIRS \${${PROJECT_NAME}_INCDIRS} PARENT_SCOPE)
    set(${PROJECT_NAME}_SRCS \${${PROJECT_NAME}_SRCS} PARENT_SCOPE)
    set(${PROJECT_NAME}_AGCMAKELISTS_VER 2)
endif()
# /exports =============================================================================================================


# output ===============================================================================================================

include_directories(${PROJECT_INCDIRS} ${CHILDS_INCDIRS})

message(STATUS "===> ${PROJECT_NAME} is loaded")

if(${PROJECT_NAME}_INCDIRS)
    message(STATUS "          Exported ${PROJECT_NAME}_INCDIRS: ${${PROJECT_NAME}_INCDIRS}")
endif()

if(${PROJECT_NAME}_SRCS)
    message(STATUS "          Exported ${PROJECT_NAME}_SRCS: ${${PROJECT_NAME}_SRCS}")
endif()

message(STATUS "          Child Includes: ${CHILDS_INCDIRS}")
message(STATUS "          Child Sources: ${CHILDS_SRCS}")

# /output ==============================================================================================================

add_executable(${PROJECT_NAME} ${MAIN_SRC} ${PROJECT_SRC} ${CHILDS_SRCS})
#add_library(${PROJECT_NAME} ${PROJECT_SRC} ${PROJECT_INCLUDES})