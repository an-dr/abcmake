# abcmake config:
cmake_minimum_required(VERSION 3.13)
set(ABC_CHILDS)
set(ABC_USE_PROJECT_ROOT "FALSE")

# abcmake
include(abcmake/ab.cmake)

## post-abcmake, if needed
# add_executable(main main.cpp)
# target_link_libraries(main ${PROJECT_NAME})
