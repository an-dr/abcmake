cmake_minimum_required(VERSION 3.15.0)

project("exclamation")

# Library

include($ENV{ABCMAKE_PATH}/ab.cmake)
add_component(${PROJECT_NAME} 
              INCLUDE_DIR "./interface" 
              SOURCE_DIR "./source_code")
