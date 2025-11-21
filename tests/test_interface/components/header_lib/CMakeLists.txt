cmake_minimum_required(VERSION 3.15)
project(header_lib)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_component(${PROJECT_NAME} INTERFACE)
