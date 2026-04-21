include_guard(GLOBAL)

# Assigns a specified IDE folder to a list of library targets for better project organization.
# Arguments:
#   FOLDER  The target folder name used by IDEs (e.g., Visual Studio, Xcode).
#   
#   LIBS    A list of library targets to assign to the specified folder.
#           For each target in LIBS, the function resolves possible ALIASED_TARGET references
#           and applies the FOLDER property so that the targets are grouped under the given
#           folder in the project structure.
function(add_libraries_to_folder)
    cmake_parse_arguments(PARSE_ARGV 0 "args" "" "FOLDER" "LIBS")
    set_property(
        GLOBAL 
        PROPERTY 
            USE_FOLDERS ON
    )
    foreach(_lib IN LISTS args_LIBS)
        get_target_property(_aliased ${_lib} ALIASED_TARGET)
        if(_aliased)
            set(_lib ${_aliased})
        endif()
        set_target_properties(
                ${_lib}
                PROPERTIES 
                    FOLDER ${args_FOLDER}
            )
    endforeach()
endfunction()