cmake_minimum_required(VERSION 3.15.0)

project("exclamation")

# Library
add_library(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE "src/exclamation.cpp")
target_include_directories(${PROJECT_NAME} PUBLIC "include")
