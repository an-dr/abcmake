cmake_minimum_required(VERSION 3.22)

include($ENV{ABCMAKE_PATH}/ab.cmake)

project(HelloWorld)

add_executable(${PROJECT_NAME})
# target_init_abcmake(${PROJECT_NAME})
target_add_abcmake_component(${PROJECT_NAME} ./lib_world)
target_add_abcmake_component(${PROJECT_NAME} ./lib_exclamation)

target_link_libraries(${PROJECT_NAME} PRIVATE exclamation)
