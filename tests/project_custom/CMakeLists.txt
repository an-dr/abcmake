cmake_minimum_required(VERSION 3.5)

include($ENV{ABCMAKE_PATH}/ab.cmake)

project(HelloWorld)

add_main_component(${PROJECT_NAME} 
                   INCLUDE_DIR "./includes" 
                   SOURCE_DIR "./sources")

target_link_components(${PROJECT_NAME} ./lib_world
                                       ./lib_exclamation)

target_link_libraries(${PROJECT_NAME} PRIVATE exclamation)
