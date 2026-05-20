include_guard(GLOBAL)
#[==[
DESCRIPTION:
    Prepends a specified IDE folder to a list of targets for better project organization.
 
SYNOPSIS:
    prepend_folder_to_targets(FOLDER folder TARGETS tgt...)
 
ARGUMENTS:
    FOLDER  (Required) The target folder name used by IDEs (e.g., Visual Studio, Xcode).
    
    TARGETS (Required) A list of targets to prepend to the specified folder.
            For each target in TARGETS, the function resolves possible aliases
            and preprnds the FOLDER property if exists, so that the targets are grouped under the given
            folder in the project structure.
]==]
function(prepend_folder_to_targets)
    cmake_parse_arguments(PARSE_ARGV 0 "args" "" "FOLDER" "TARGETS")

    set_property(
        GLOBAL 
        PROPERTY 
            USE_FOLDERS ON
    )

    foreach(_tgt IN LISTS args_TARGETS)
        get_target_property(
            _aliased 
            ${_tgt} 
                ALIASED_TARGET
        )

        if(_aliased)
            set(_tgt ${_aliased})
        endif()

        get_target_property(
            _subfolder 
            ${_tgt} 
                FOLDER
        )

        if(NOT "${_subfolder}" STREQUAL "_subfolder-NOTFOUND")
            cmake_path(
                APPEND args_FOLDER 
                ${_subfolder} 
                OUTPUT_VARIABLE _final_folder
            )
        else()
            cmake_path(
                SET
                _final_folder
                ${args_FOLDER} 
            )
        endif()

        set_target_properties(
            ${_tgt}
            PROPERTIES 
                FOLDER ${_final_folder}
        )
    endforeach()
endfunction()