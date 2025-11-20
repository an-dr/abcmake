# ==============================================================================
# add_component.cmake ==========================================================

include(CMakeParseArguments)
set(ABC_INSTALL_LIB_SUBDIR ".")
set(ABC_INSTALL_EXE_SUBDIR ".")

# Add all projects from the components subdirectory
# @param PROCESS_LEVEL - level of the recursion
# @param TARGETNAME - name of the target to add components
function(_abcmake_add_components PROCESS_LEVEL TARGETNAME)

    # Get component directory
    _abcmake_get_components(components)

    # List of possible subprojects
    file(GLOB children RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/${components} ${CMAKE_CURRENT_SOURCE_DIR}/${components}/*)
    
    # Link all subprojects to the ${TARGETNAME}
    foreach(child ${children})
        if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${components}/${child})
            _abcmake_target_link_components(${PROCESS_LEVEL} 
                                            ${TARGETNAME} 
                                            PATH ${CMAKE_CURRENT_SOURCE_DIR}/${components}/${child})
        endif()
    endforeach()
    
endfunction()

# Add all source files from the specified directory to the target
# @param TARGETNAME - name of the target to add sources
# @param SOURCE_DIR - path to the source directory
# @param INTERFACE - if set, use INTERFACE visibility instead of PRIVATE
function(target_sources_directory TARGETNAME SOURCE_DIR)
    cmake_parse_arguments(arg "INTERFACE" "" "" ${ARGN})
    file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.cpp" "${SOURCE_DIR}/*.c")
    message(DEBUG "[target_sources_directory] ${TARGETNAME} sources: ${SOURCES}")
    if (arg_INTERFACE)
        target_sources(${TARGETNAME} INTERFACE ${SOURCES})
    else()
        target_sources(${TARGETNAME} PRIVATE ${SOURCES})
    endif()
endfunction()

# Install the target near the build directory
# @param TARGETNAME - name of the target to install
# @param DESTINATION - path to the destination directory inside the install dir
function(_abcmake_target_install TARGETNAME DESTINATION)
    # install directory
    _abcmake_get_install(install_dir)
    set (CMAKE_INSTALL_PREFIX ${install_dir}
         CACHE PATH "default install path" FORCE)
    message(DEBUG "[_abcmake_target_install] Install target: ${TARGETNAME}")
    install(TARGETS ${TARGETNAME} DESTINATION ${DESTINATION})
    
    # install include directories
    _abcmake_get_prop_dir(${CMAKE_CURRENT_SOURCE_DIR} ${ABCMAKE_DIRPROP_INCLUDE} include_dir)
    message(DEBUG "[_abcmake_target_install] Install include: ${include_dir}")
    install(DIRECTORY ${include_dir} DESTINATION ${DESTINATION})
    
endfunction()


function(_abcmake_count_parents OUT_PARENT_NUM)
    set(PARENT_NUM 0)
    get_directory_property(parent PARENT_DIRECTORY)
    while (parent)
        math(EXPR PARENT_NUM "${PARENT_NUM} + 1")
        set(parent "")
        get_directory_property(hasParent PARENT_DIRECTORY)
    endwhile()
    set(${OUT_PARENT_NUM} ${PARENT_NUM} PARENT_SCOPE)
endfunction()

# Add to the project all files from ./src, ./include, ./lib
# @param TARGETNAME - name of the target to initialize
# @param INCLUDE_DIR - path to the include directory
# @param SOURCE_DIR - path to the source directory
# @param INTERFACE - if set, treat as interface library (sources compile in consumer)
function(_abcmake_target_init TARGETNAME)
    set(flags INTERFACE)
    set(args)
    set(listArgs INCLUDE_DIR SOURCE_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    if (NOT arg_SOURCE_DIR)
        set(arg_SOURCE_DIR "src")  # TODO: replace with _abcmake_get_src?
    endif()

    if (NOT arg_INCLUDE_DIR)
        set(arg_INCLUDE_DIR "include")  # TODO: replace with _abcmake_get_include?
    endif()

    _abcmake_count_parents(parents_num)
    set(process_level ${parents_num})
    # if no parent, print the name of the target
    if (parents_num EQUAL 0)
        _abcmake_log_header(${process_level} "${TARGETNAME}")
    endif ()
    
    # Report version
    _abcmake_set_prop_curdir(${ABCMAKE_DIRPROP_VERSION} ${ABCMAKE_VERSION})
    
    # Set name
    _abcmake_set_prop_curdir(${ABCMAKE_DIRPROP_COMPONENT_NAME} ${PROJECT_NAME})
    
    # Add target to the target list
    _abcmake_append_prop_curdir(${ABCMAKE_DIRPROP_TARGETS} ${TARGETNAME})

    foreach(s ${arg_SOURCE_DIR})
        if (arg_INTERFACE)
            target_sources_directory(${TARGETNAME} ${s} INTERFACE)
        else()
            target_sources_directory(${TARGETNAME} ${s})
        endif()
    endforeach()

    if (arg_INTERFACE)
        target_include_directories(${TARGETNAME} INTERFACE ${arg_INCLUDE_DIR})
    else()
        target_include_directories(${TARGETNAME} PUBLIC ${arg_INCLUDE_DIR})
    endif()
    _abcmake_add_components(${process_level} ${TARGETNAME})

endfunction()

# Add a component set that only registers nested components (no targets)
# @param PATH - base directory containing components (defaults to abcmake components dir)
# @param COMPONENTS - names of subdirectories to register
# @param REGISTER_ALL - if set, register every subdirectory under PATH
function(add_component_set)
    set(flags REGISTER_ALL)
    set(args)
    set(listArgs PATH COMPONENTS)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    if (NOT arg_PATH)
        _abcmake_get_components(arg_PATH)
    endif()

    set(base_dir ${arg_PATH})
    if (NOT IS_ABSOLUTE "${base_dir}")
        set(base_dir "${CMAKE_CURRENT_SOURCE_DIR}/${base_dir}")
    endif()

    set(to_register ${arg_COMPONENTS})

    if (arg_REGISTER_ALL)
        file(GLOB children RELATIVE "${base_dir}" "${base_dir}/*")
        foreach(child ${children})
            if (IS_DIRECTORY "${base_dir}/${child}")
                list(APPEND to_register ${child})
            endif()
        endforeach()
    endif()

    list(REMOVE_DUPLICATES to_register)
    foreach(child ${to_register})
        register_components("${base_dir}/${child}")
    endforeach()

    _abcmake_set_prop_curdir(${ABCMAKE_DIRPROP_VERSION} ${ABCMAKE_VERSION})
    _abcmake_set_prop_curdir(${ABCMAKE_DIRPROP_COMPONENT_NAME} ${PROJECT_NAME})
    _abcmake_set_prop_curdir(${ABCMAKE_DIRPROP_TARGETS} "")
    _abcmake_log_header(0 "${PROJECT_NAME} (component set)")
endfunction()

# Add an executable component to the project
# @param TARGETNAME - name of the target to add the component
# @param INCLUDE_DIR - path to the include directory
# @param SOURCE_DIR - path to the source directory
function(add_main_component TARGETNAME)
    set(flags)
    set(args)
    set(listArgs INCLUDE_DIR SOURCE_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    
    if (NOT arg_SOURCE_DIR)
        _abcmake_get_src(arg_SOURCE_DIR)
    endif()
    
    if (NOT arg_INCLUDE_DIR)
        _abcmake_get_include(arg_INCLUDE_DIR)
        if (EXISTS "include")
            set(arg_INCLUDE_DIR "include")
        else()
            set(arg_INCLUDE_DIR "")
        endif()
    endif()
    
    message(DEBUG "[add_main_component] TARGETNAME: ${TARGETNAME}")
    message(DEBUG "[add_main_component] INCLUDE_DIR: ${arg_INCLUDE_DIR}")
    message(DEBUG "[add_main_component] SOURCE_DIR: ${arg_SOURCE_DIR}")
    
    # Set Component Src and Include
    _abcmake_set_prop_curdir("${ABCMAKE_DIRPROP_SRC}" "${arg_SOURCE_DIR}")
    _abcmake_set_prop_curdir("${ABCMAKE_DIRPROP_INCLUDE}" "${arg_INCLUDE_DIR}")
    
    add_executable(${TARGETNAME})
    _abcmake_target_init(${TARGETNAME} 
                         INCLUDE_DIR ${arg_INCLUDE_DIR} 
                         SOURCE_DIR ${arg_SOURCE_DIR})
    _abcmake_target_install(${TARGETNAME} ${ABC_INSTALL_EXE_SUBDIR})
endfunction()

# Add a shared or static library component to the project
# @param TARGETNAME - name of the target to add the component
# @param INCLUDE_DIR - paths to the include directories
# @param SOURCE_DIR - paths to the source directories
# @param SHARED - if set, the library will be shared
# @param INTERFACE - if set, the library will be an interface library
function(add_component TARGETNAME)
    set(flags SHARED INTERFACE)
    set(args)
    set(listArgs INCLUDE_DIR SOURCE_DIR)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})
    
    if (NOT arg_SOURCE_DIR)
        _abcmake_get_src(arg_SOURCE_DIR)
    endif()

    if (NOT arg_INCLUDE_DIR)
        _abcmake_get_include(arg_INCLUDE_DIR)
        if (EXISTS "include")
            set(arg_INCLUDE_DIR "include")
        else()
            set(arg_INCLUDE_DIR "")
        endif()
    endif()

    if (arg_INTERFACE)
        add_library(${TARGETNAME} INTERFACE)
    elseif (arg_SHARED)
        add_library(${TARGETNAME} SHARED)
    else()
        add_library(${TARGETNAME} STATIC)
    endif()

    message(DEBUG "[add_component] TARGETNAME: ${TARGETNAME}")
    message(DEBUG "[add_component] INCLUDE_DIR: ${arg_INCLUDE_DIR}")
    message(DEBUG "[add_component] SOURCE_DIR: ${arg_SOURCE_DIR}")
    message(DEBUG "[add_component] SHARED: ${arg_SHARED}")
    message(DEBUG "[add_component] INTERFACE: ${arg_INTERFACE}")

    # Set Component Src and Include
    _abcmake_set_prop_curdir("${ABCMAKE_DIRPROP_SRC}" "${arg_SOURCE_DIR}")
    _abcmake_set_prop_curdir("${ABCMAKE_DIRPROP_INCLUDE}" "${arg_INCLUDE_DIR}")

    if (arg_INTERFACE)
        _abcmake_target_init(${TARGETNAME}
                             INTERFACE
                             INCLUDE_DIR ${arg_INCLUDE_DIR}
                             SOURCE_DIR ${arg_SOURCE_DIR})
    else()
        _abcmake_target_init(${TARGETNAME}
                             INCLUDE_DIR ${arg_INCLUDE_DIR}
                             SOURCE_DIR ${arg_SOURCE_DIR})
        _abcmake_target_install(${TARGETNAME} ${ABC_INSTALL_LIB_SUBDIR})
    endif()
endfunction()

# add_component.cmake ==========================================================
# ==============================================================================

