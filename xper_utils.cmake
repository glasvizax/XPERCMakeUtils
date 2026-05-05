include_guard(GLOBAL)
# This is a helper file that includes all .cmake files in it's directory

cmake_path(APPEND ${CMAKE_CURRENT_LIST_DIR} "*.cmake" OUTPUT_VARIABLE current_path_glob)

file(GLOB_RECURSE xper_utils_files ${current_path_glob})

foreach(file IN LISTS xper_utils_files)
    include(${file})
endforeach()

return(PROPAGATE xper_utils_files)