# Copies files from <source_dir> to the <target>'s output directory, preserving
# the folder structure. Uses stamp files for fast, reliable incremental builds.
#
# Usage:
#   add_copy_dir_dependency(<target> <source_dir>
#                           [INCLUDE_REGEX <regex>...]
#                           [EXCLUDE_REGEX <regex>...])
#
# Arguments:
#   <target>      - Existing target. Files go to its $<TARGET_FILE_DIR:...>.
#   <source_dir>  - Directory containing files to copy (relative or absolute).
#   INCLUDE_REGEX - (Optional) Copy ONLY files matching these regex patterns.
#   EXCLUDE_REGEX - (Optional) Exclude files matching these regex patterns.
#
# Example:
#   add_copy_dir_dependency(MyApp "assets" INCLUDE_REGEX "\\.png$|\\.json$" EXCLUDE_REGEX "^tests/")
function(add_copy_dir_dependency target source_dir)
    if(NOT TARGET "${target}")
        message(FATAL_ERROR "Target '${target}' does not exist")
    endif()

    if(NOT IS_DIRECTORY "${source_dir}")
        message(FATAL_ERROR "Source directory '${source_dir}' does not exist")
    endif()

    if(NOT IS_ABSOLUTE ${source_dir})
        cmake_path(ABSOLUTE_PATH source_dir)
    endif()

    cmake_parse_arguments(PARSE_ARGV 2 rgx "" "" "INCLUDE_REGEX;EXCLUDE_REGEX")

    file(GLOB_RECURSE _copy_files CONFIGURE_DEPENDS
        "${source_dir}/*"
    )

    if(rgx_INCLUDE_REGEX)
        set(_temp_files "")
        foreach(_regex IN LISTS rgx_INCLUDE_REGEX)
            set(_sub_list "${_copy_files}")
            list(FILTER _sub_list INCLUDE REGEX "${_regex}")
            list(APPEND _temp_files ${_sub_list})
        endforeach()
        list(REMOVE_DUPLICATES _temp_files)
        set(_copy_files "${_temp_files}")
    endif()

    if(rgx_EXCLUDE_REGEX)
        foreach(_regex IN LISTS rgx_EXCLUDE_REGEX)
            list(FILTER _copy_files EXCLUDE REGEX "${_regex}")
        endforeach()
    endif()
    
    foreach(_file IN LISTS _copy_files)
        cmake_path(RELATIVE_PATH _file BASE_DIRECTORY "${source_dir}" OUTPUT_VARIABLE _path)
        cmake_path(GET _path PARENT_PATH _parent_path)
        cmake_path(GET _path FILENAME _name)

        set(_stamp_file "${CMAKE_CURRENT_BINARY_DIR}/_copy_stamps/${target}/${_name}.stamp")
        cmake_path(GET _stamp_file PARENT_PATH _stamp_dir)

        set(_dest_path "$<TARGET_FILE_DIR:${target}>/${_path}")
        set(_dest_dir "$<TARGET_FILE_DIR:${target}>/${_parent_path}")

        add_custom_command(
            OUTPUT "${_stamp_file}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${_stamp_dir}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${_dest_dir}"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_file}" "${_dest_path}"
            COMMAND "${CMAKE_COMMAND}" -E touch "${_stamp_file}"
            DEPENDS "${_file}"
            COMMENT "Copying ${_name} to target directory"
            VERBATIM
        )

        list(APPEND _stamp_files ${_stamp_file})
    endforeach()

    if(_stamp_files)
        add_custom_target("${target}_copy_files" DEPENDS ${_stamp_files})
        set_target_properties("${target}_copy_files" PROPERTIES FOLDER "_add_copy_dir_dependency_targets")
        add_dependencies("${target}" "${target}_copy_files")
    endif()
endfunction()
