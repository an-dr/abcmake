cmake_minimum_required(VERSION 3.5)
project(HelloWorld)

# Find the installed abcmake package
# If abcmake is installed system-wide, CMake will find it automatically
# Otherwise, you may need to set CMAKE_PREFIX_PATH to the installation directory
find_package(abcmake REQUIRED)

# Now all abcmake functions are available
add_main_component(${PROJECT_NAME})
