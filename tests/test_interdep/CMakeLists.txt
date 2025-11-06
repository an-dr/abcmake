cmake_minimum_required(VERSION 3.15)
project(Main)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_main_component(${PROJECT_NAME})
