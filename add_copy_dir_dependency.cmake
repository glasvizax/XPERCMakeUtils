include_guard(GLOBAL)
include(add_targets_to_folder)

# ==============================================================================
# add_copy_dir_dependency
# ==============================================================================
#
# Copies the contents of a directory to a target's output directory during the
# build phase. It creates custom commands for incremental copying and sets up
# the required build dependencies.
#
# SYNOPSIS:
#   add_copy_dir_dependency(
#       TARGET <target>
#       DIRECTORY <dir>
#       [INCLUDE_ROOT]
#       [CONDITION <genex>]
#       [INCLUDE_REGEX <regex>...]
#       [EXCLUDE_REGEX <regex>...]
#   )
#
# OPTIONS:
#   TARGET          (Required) The existing target whose output directory 
#                   will be the destination.
#
#   DIRECTORY       (Required) The source directory to copy. Can be an absolute 
#                   path or a relative path to CMAKE_CURRENT_SOURCE_DIR.
#
#   INCLUDE_ROOT    (Optional) If present, the base directory itself is created 
#                   in the destination, rather than just copying its contents.
#
#   CONDITION       (Optional) A generator expression (e.g., $<CONFIG:Debug>) 
#                   that evaluates to 1 or 0. If 0, the copy operation is skipped 
#                   at build time. Defaults to "1".
#
#   INCLUDE_REGEX   (Optional) A list of regular expressions. Only files 
#                   matching at least one of these regexes will be copied.
#
#   EXCLUDE_REGEX   (Optional) A list of regular expressions. Files matching 
#                   any of these regexes will NOT be copied.
#
# ==============================================================================

function(add_copy_dir_dependency)
    cmake_parse_arguments(
        PARSE_ARGV 0 
        arg 
        "INCLUDE_ROOT" 
        "TARGET;DIRECTORY;CONDITION" 
        "INCLUDE_REGEX;EXCLUDE_REGEX"
    )

    if(NOT TARGET "${arg_TARGET}")
        message(FATAL_ERROR "Target '${arg_TARGET}' does not exist")
    endif()

    if(NOT IS_DIRECTORY "${arg_DIRECTORY}")
        message(FATAL_ERROR "Source directory '${arg_DIRECTORY}' does not exist")
    endif()

    if(NOT IS_ABSOLUTE ${arg_DIRECTORY})
        cmake_path(SET _dir_rel ${arg_DIRECTORY})
        cmake_path(ABSOLUTE_PATH arg_DIRECTORY OUTPUT_VARIABLE _dir_abs)
    else()  
        cmake_path(SET _dir_abs ${arg_DIRECTORY})
        cmake_path(RELATIVE_PATH arg_DIRECTORY OUTPUT_VARIABLE _dir_rel)
    endif()

    file(GLOB_RECURSE _copy_files CONFIGURE_DEPENDS
        "${_dir_abs}/*"
    )

    if(arg_INCLUDE_REGEX)
        foreach(_regex IN LISTS arg_INCLUDE_REGEX)
            set(_sub_list "${_copy_files}")
            list(FILTER _sub_list INCLUDE REGEX "${_regex}")
            list(APPEND _temp_files ${_sub_list})
        endforeach()
        list(REMOVE_DUPLICATES _temp_files)
        set(_copy_files "${_temp_files}")
    endif()

    if(arg_EXCLUDE_REGEX)
        foreach(_regex IN LISTS arg_EXCLUDE_REGEX)
            list(FILTER _copy_files EXCLUDE REGEX "${_regex}")
        endforeach()
    endif()
    
    foreach(_file IN LISTS _copy_files)
        cmake_path(RELATIVE_PATH _file BASE_DIRECTORY "${_dir_abs}" OUTPUT_VARIABLE _path)
        if(arg_INCLUDE_ROOT)
            cmake_path(GET _path PARENT_PATH _parent)
            cmake_path(APPEND _dir_rel ${_parent} OUTPUT_VARIABLE _parent_path)
        else()
            cmake_path(GET _path PARENT_PATH _parent_path)
        endif()
       
        cmake_path(GET _path FILENAME _name)
        cmake_path(
            APPEND CMAKE_CURRENT_BINARY_DIR 
            "_copy_stamps" 
            "${arg_TARGET}" 
            "${_dir_rel}" 
            "${_path}.stamp" 
            OUTPUT_VARIABLE _stamp_file
        )
        cmake_path(GET _stamp_file PARENT_PATH _stamp_dir)

        cmake_path(SET _dest_dir "$<TARGET_FILE_DIR:${arg_TARGET}>")
        cmake_path(APPEND _dest_dir "${_parent_path}")
        cmake_path(APPEND _dest_dir "${_name}" OUTPUT_VARIABLE _dest_path)

        if(NOT arg_CONDITION)
            set(arg_CONDITION "1")
        endif()
        
        add_custom_command(
            OUTPUT "${_stamp_file}"
            COMMAND "${CMAKE_COMMAND}" -E "$<IF:${arg_CONDITION},make_directory;${_stamp_dir},true>"
            COMMAND "${CMAKE_COMMAND}" -E "$<IF:${arg_CONDITION},make_directory;${_dest_dir},true>"
            COMMAND "${CMAKE_COMMAND}" -E "$<IF:${arg_CONDITION},copy_if_different;${_file};${_dest_path},true>"
            COMMAND "${CMAKE_COMMAND}" -E "$<IF:${arg_CONDITION},touch;${_stamp_file},true>"
            DEPENDS "${_file}"
            COMMENT "Copying ${_name} to target directory"
            VERBATIM
            COMMAND_EXPAND_LISTS
        )
        list(APPEND _stamp_files ${_stamp_file})
    endforeach()

    if(_stamp_files)
        string(MAKE_C_IDENTIFIER "${arg_TARGET}_${_dir_rel}_copy_files" _tgt_name)
        add_custom_target(${_tgt_name} DEPENDS ${_stamp_files})
        add_dependencies("${arg_TARGET}" ${_tgt_name})
        add_targets_to_folder(FOLDER "XPERInternalTargets" TARGETS ${_tgt_name})
    endif()
endfunction()
