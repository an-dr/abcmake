cmake_minimum_required(VERSION 3.15)
project(ComponentSetMain)

include($ENV{ABCMAKE_PATH}/ab.cmake)

add_main_component(${PROJECT_NAME})
target_link_components(${PROJECT_NAME}
    PATH ${CMAKE_CURRENT_LIST_DIR}/components/aggregator
    NAME nested_hello)
