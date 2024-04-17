cmake_minimum_required(VERSION 3.0)
project(HelloWorld)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_main_component(${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME} PRIVATE exclamation)
