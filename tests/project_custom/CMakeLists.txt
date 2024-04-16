cmake_minimum_required(VERSION 3.22)

include($ENV{ABCMAKE_PATH}/ab.cmake)

project(HelloWorld)

add_executable(${PROJECT_NAME})
# target_init_abcmake(${PROJECT_NAME})
target_abcmake_component(${PROJECT_NAME} ./lib_world)
target_abcmake_component(${PROJECT_NAME} ./lib_exclamation)

target_sources_directory(${PROJECT_NAME} ./sources)
target_include_directories(${PROJECT_NAME} PRIVATE ./includes)

target_link_libraries(${PROJECT_NAME} PRIVATE exclamation)
