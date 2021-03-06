# abcmake

Cmake-based extension to work with CMake projects in a python modules style. 
Define only folder structure and imported of Child (nested projects)

Common project structure:

```
+[PROJECT_NAME]
|
|---[abcmake]
|---[include]
|---[src]
|
|--+[sub_project1]
|  |--+[sub_sub_project]
|  |  |--[abcmake]
|  |  |--[include]
|  |  |--[src]
|  |  '--CMakeLists.txt
|  |---[abcmake]
|  |---[include]
|  |---[src]
|  '---CMakeLists.txt
|
|--+[sub_project2]
|  |---[abcmake]
|  |---[include]
|  |---[src]
|  '---CMakeLists.txt
|
'---CMakeLists.txt
```

## How to turn your sources into abcmake project

1. Create a folder i.e. `PROJECT_NAME`
2. Move all headers and sources to `PROJECT_NAME/include` and `PROJECT_NAME/src` folders respectively
3. Copy `abcmake` folder to `PROJECT_NAME`
4. Copy `abcmake/CMakeList.txt` to  `PROJECT_NAME`

If you want to add a sub-project:
- Init it with 1-4 steps (e.g in `SubProject`)
- Copy `SubProject` to `PROJECT_NAME`
- Add `SubProject` into `Project\CMakeFiles.txt` into line 3:
```cmake
cmake_minimum_required(VERSION 3.13)

set(CHILDS SubProject)
include(abcmake/ab.cmake)

## Test exe - if needed
#add_executable(main main.cpp)
#target_link_libraries(main ${PROJECT_NAME})

```

## Working with CLion
Just follow the folder structure. CLion works perfectly


## How-to build a lib with Ninja
Execute:
```
./abcmake/install_w_ninja.ps1
```
or 
```
./abcmake/install_w_ninja.sh
```

You'll get folders:
```
PROJECT_NAME_lib/include
PROJECT_NAME_lib/lib
PROJECT_NAME_lib/src
```
You could use it in any ide with other projects