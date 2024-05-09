cmake_minimum_required(VERSION 3.5)
project(Main)

include($ENV{ABCMAKE_PATH}/ab.cmake)

register_component(${CMAKE_CURRENT_LIST_DIR}/components_to_register/world)

add_main_component(${PROJECT_NAME})
