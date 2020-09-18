# abcmake config:
cmake_minimum_required(VERSION 3.13)
set(ABC_CHILDS) # specify here abcmake folders that will be build as subprojects
set(ABC_USE_PROJECT_ROOT "FALSE") # set true if you have sources at the root of your project

# abcmake
include(abcmake/ab.cmake)

## post-abcmake, if needed
add_executable(main main.cpp)
# target_link_libraries(main ${PROJECT_NAME})
