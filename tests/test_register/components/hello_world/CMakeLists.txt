cmake_minimum_required(VERSION 3.5)
project(hello_world)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_component(${PROJECT_NAME})
target_register_dependency(${PROJECT_NAME} world)
