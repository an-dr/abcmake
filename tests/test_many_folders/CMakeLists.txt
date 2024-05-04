cmake_minimum_required(VERSION 3.5)
project(Main)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_main_component(${PROJECT_NAME} INCLUDE_DIR include1 include2
                                   SOURCE_DIR src1 src2)
