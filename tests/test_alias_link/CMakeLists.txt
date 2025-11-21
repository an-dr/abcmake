cmake_minimum_required(VERSION 3.15)
project(AliasConsumer)

add_subdirectory(component_proj)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE nested_alias::nested_alias)
