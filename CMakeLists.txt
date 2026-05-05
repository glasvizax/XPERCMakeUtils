cmake_minimum_required(VERSION 3.30)

project(XPERCMakeUtils VERSION 1.4)

include(xper_utils.cmake)

add_library(XPER_CMakeUtils INTERFACE EXCLUDE_FROM_ALL ${xper_utils_files})

add_library(XPER::CMakeUtils ALIAS XPER_CMakeUtils)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

return(PROPAGATE CMAKE_MODULE_PATH)