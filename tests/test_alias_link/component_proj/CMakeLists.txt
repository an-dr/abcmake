cmake_minimum_required(VERSION 3.15)
project(NestedAliasProject)

include($ENV{ABCMAKE_PATH}/ab.cmake)

add_component(nested_alias
    INCLUDE_DIR include
    SOURCE_DIR src)
