include_guard(GLOBAL)

cmake_path(SET __current_path ${CMAKE_CURRENT_LIST_DIR})
cmake_path(APPEND __current_path "*" OUTPUT_VARIABLE __current_path_glob)

file(GLOB_RECURSE __xper_util_files ${__current_path_glob})

foreach(__file IN LISTS __xper_util_files)
    include(${__file})
endforeach()