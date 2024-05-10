cmake_minimum_required(VERSION 3.5)
project(Main)

include($ENV{ABCMAKE_PATH}/ab.cmake)

register_components(${CMAKE_CURRENT_LIST_DIR}/to_register/world
                   ${CMAKE_CURRENT_LIST_DIR}/to_register/hello_world)
add_main_component(${PROJECT_NAME})
target_link_components(${PROJECT_NAME} NAME World hello_world)
