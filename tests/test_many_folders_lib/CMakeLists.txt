cmake_minimum_required(VERSION 3.5)
project(many_folders_lib)

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_component(${PROJECT_NAME} INCLUDE_DIR include1 include2
                                   SOURCE_DIR src1 src2)
