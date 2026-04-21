cmake_minimum_required(VERSION 3.30)

project(XPERCMakeUtils VERSION 1.2)

cmake_path(SET __current_path ${CMAKE_CURRENT_SOURCE_DIR})
cmake_path(APPEND __current_path "*.cmake" OUTPUT_VARIABLE __current_path_glob)

file(GLOB_RECURSE __xper_util_files ${__current_path_glob})

add_library(XPER_CMakeUtils INTERFACE EXCLUDE_FROM_ALL ${__xper_util_files})

add_library(XPER::CMakeUtils ALIAS XPER_CMakeUtils)
