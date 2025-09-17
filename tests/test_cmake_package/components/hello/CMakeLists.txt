cmake_minimum_required(VERSION 3.5)
project(Hello)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_component(${PROJECT_NAME})
