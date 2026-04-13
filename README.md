# XPERCMakeUtils

my custom cmake utils library

## function for download library through cmake:

```cmake
# xper_fetch_utils(<Options>)
#
# Downloads or reuses the XPERCMakeUtils module set and optionally includes
# the requested CMake modules automatically.
#
# Options:
#   FETCH_ALL     Download the full XPERCMakeUtils archive if it is not
#                 already present in the local cmake/ directory.
#   FETCH <list>  Download only the specified .cmake modules from the
#                 XPERCMakeUtils repository.
#   AUTO_INCLUDE  Include downloaded or existing modules immediately after
#                 fetching.
#
# Behavior:
#   - Adds the downloaded utility directory to CMAKE_MODULE_PATH.
#   - If FETCH_ALL is used, the function downloads the full archive for the
#     tag stored in XPERCMakeUtils_TAG.
#   - If FETCH is used, each listed module is downloaded individually.
#   - If a module already exists locally, it is reused instead of downloaded.
#
# Example:
#   1) xper_fetch_utils(FETCH_ALL AUTO_INCLUDE)
#   2) xper_fetch_utils(FETCH add_copy_dir_dependency [other_modules...] AUTO_INCLUDE)
#   3) xper_fetch_utils(FETCH add_copy_dir_dependency)
#      include(add_copy_dir_dependency [...])
#   4) xper_fetch_utils(FETCH_ALL)
#      include(xper_utils [...])
set(XPERCMakeUtils_TAG "1.0")
function(xper_fetch_utils)
    set(_xper_utils_dir_name "XPERCMakeUtils-${XPERCMakeUtils_TAG}")
    cmake_path(SET _utils_dir ${CMAKE_CURRENT_SOURCE_DIR})
    cmake_path(APPEND _utils_dir cmake)
    cmake_path(APPEND _utils_dir ${_xper_utils_dir_name} OUTPUT_VARIABLE _xper_utils_dir)
    list(APPEND CMAKE_MODULE_PATH ${_xper_utils_dir})
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
    cmake_parse_arguments(PARSE_ARGV 0 args "FETCH_ALL;AUTO_INCLUDE" "" "FETCH")
    if(args_FETCH_ALL)
        if(IS_DIRECTORY ${_xper_utils_dir})
            if(args_AUTO_INCLUDE)
                cmake_path(APPEND _xper_utils_dir "xper_utils.cmake" OUTPUT_VARIABLE _xper_utils_dot_cmake)
                include(${_xper_utils_dot_cmake})
            endif()
            return()
        endif()

        set(_archive ${CMAKE_BINARY_DIR}/_xper_utils.zip)

        file(DOWNLOAD 
            https://github.com/glasvizax/XPERCMakeUtils/archive/refs/tags/v${XPERCMakeUtils_TAG}.zip 
            ${_archive}
        )

        file(ARCHIVE_EXTRACT
            INPUT ${_archive}
            DESTINATION ${_utils_dir}
        )

        file(REMOVE ${_archive})

        if(args_AUTO_INCLUDE)
            cmake_path(APPEND _xper_utils_dir "xper_utils.cmake" OUTPUT_VARIABLE _xper_utils_dot_cmake)
            include(${_xper_utils_dot_cmake})
        endif()
    else()
        if(NOT args_FETCH)
            message(WARNING "not a single file is specified in FETCH, nor FETCH_ALL")
            return()
        endif()

        file(MAKE_DIRECTORY ${_xper_utils_dir})
        foreach(_module IN LISTS args_FETCH)
            cmake_path(GET _module EXTENSION LAST_ONLY _ext)

            if(NOT _ext STREQUAL ".cmake")
                string(APPEND _module ".cmake")
            endif() 

            cmake_path(APPEND _xper_utils_dir ${_module} OUTPUT_VARIABLE _xper_util_path)
            if(EXISTS ${_xper_util_path})
                if(args_AUTO_INCLUDE)
                    include(${_xper_util_path})
                endif() 
                continue()
            endif()

            file(DOWNLOAD
                https://raw.githubusercontent.com/glasvizax/XPERCMakeUtils/refs/tags/v${XPERCMakeUtils_TAG}/${_module}
                ${_xper_util_path}
            )

            if(args_AUTO_INCLUDE)
                include(${_xper_util_path})
            endif() 
        endforeach()
    endif() 
endfunction()
```