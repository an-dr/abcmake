cmake_minimum_required(VERSION 3.5)

include($ENV{ABCMAKE_PATH}/ab.cmake)
set_abcmake_project_structure(
    INCLUDE_DIR "headers"
    SRC_DIR "sources"
    COMPONENTS_DIR "libs"
)

project(HelloWorld)

add_main_component(${PROJECT_NAME})

target_link_component(${PROJECT_NAME} ./lib_world)
target_link_component(${PROJECT_NAME} ./lib_exclamation)

target_link_libraries(${PROJECT_NAME} PRIVATE exclamation)
