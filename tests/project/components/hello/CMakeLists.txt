cmake_minimum_required(VERSION 3.5)

include($ENV{ABCMAKE_PATH}/ab.cmake)

project(Hello)
add_library(${PROJECT_NAME})
target_init_abcmake(${PROJECT_NAME})
