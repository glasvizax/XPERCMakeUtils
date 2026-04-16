include_guard(GLOBAL)
# Downloads stb headers, generates a single implementation file, and creates
# a `stb` library target with the downloaded directory added to its include path.
# Arguments:
#   HEADERS   A list of stb headers to fetch. Each item may be given with or
#             without the `.h` extension, for example:
#             `stb_image` or `stb_image.h`.
#   SRC_PATH  Optional base directory where the `stb/` folder will be created.
#             If omitted, the function uses the current binary directory when
#             available, otherwise it falls back to the current function list
#             directory.

# Downloads stb headers, generates a single implementation file, and creates
# a `stb` library target with the downloaded directory added to its include path.
# Arguments:
#   HEADERS   A list of stb headers to fetch. Each item may be given with or
#             without the `.h` extension, for example:
#             `stb_image` or `stb_image.h`.
#   SRC_PATH  Optional base directory where the `stb/` folder will be created.
#             If omitted, the function uses the current binary directory when
#             available, otherwise it falls back to the current function list
#             directory.
function(fetch_stb)
    cmake_parse_arguments(PARSE_ARGV 0 args "" "SRC_PATH" "HEADERS")

    if(args_SRC_PATH)
        set(_stb_dir "${args_SRC_PATH}")
    elseif(IS_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
        set(_stb_dir "${CMAKE_CURRENT_BINARY_DIR}")
    else()
        set(_stb_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}")
    endif()

    cmake_path(APPEND _stb_dir "stb")
    file(MAKE_DIRECTORY ${_stb_dir})

    set(_update_cpp FALSE)
    foreach(_header IN LISTS args_HEADERS)
        cmake_path(HAS_EXTENSION _header _has_ext)
        if(NOT _has_ext)
            cmake_path(SET _header_name ${_header})
            cmake_path(APPEND_STRING _header ".h")
        else()
            cmake_path(GET _header STEM _header_name)    
        endif()

        if(EXISTS ${_stb_dir}/${_header})
            list(APPEND _headers ${_stb_dir}/${_header})
            continue()
        endif()
        file(DOWNLOAD
            https://raw.githubusercontent.com/nothings/stb/28d546d5eb77d4585506a20480f4de2e706dff4c/${_header}
            ${_stb_dir}/${_header}
            STATUS _download_status
        )

        list(GET _download_status 0 _download_status_code)

        if(_download_status_code)
            list(GET _download_status 1 _download_status_msg)
            message(WARNING "could not download file ${_header}, therefore skipped : [${_download_status_msg}]")
            file(REMOVE ${_stb_dir}/${_header})
            continue()
        endif()

        string(TOUPPER ${_header_name} _header_name_upper)
        
        string(CONCAT _tmp
            "#define ${_header_name_upper}_IMPLEMENTATION\n"
            "#include \"${_header}\"\n"
        )

        string(APPEND _stb_impl_content "${_tmp}")

        set(_update_cpp TRUE)

        list(APPEND _headers ${_stb_dir}/${_header})
    endforeach()

    if(_update_cpp)
        if(IS_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
            cmake_path(SET _stb_impl_path ${CMAKE_CURRENT_BINARY_DIR})
        else()
            cmake_path(SET _stb_impl_path ${_stb_dir})
        endif()

        cmake_path(APPEND _stb_impl_path "_stb_impl.cpp")
        
        set(_STB_IMPL_PATH_INTERNAL ${_stb_impl_path} CACHE INTERNAL "" FORCE)
        file(APPEND ${_STB_IMPL_PATH_INTERNAL} ${_stb_impl_content})
    endif()
    if(_headers)
        add_library(stb ${_STB_IMPL_PATH_INTERNAL} ${_headers})
        target_include_directories(stb PUBLIC ${_stb_dir})   
    endif()
endfunction()



