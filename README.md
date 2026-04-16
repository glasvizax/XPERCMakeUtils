# XPERCMakeUtils

my custom cmake utils library

## for download library through cmake:

```cmake
include(FetchContent)
FetchContent_Declare(
    XPERCMakeUtils
    GIT_REPOSITORY https://github.com/glasvizax/XPERCMakeUtils
    GIT_TAG v1.1
    SYSTEM
)

FetchContent_MakeAvailable(XPERCMakeUtils)

message(STATUS "XPERCMakeUtils source dir: ${XPERCMakeUtils_SOURCE_DIR}")

list(APPEND CMAKE_MODULE_PATH "${XPERCMakeUtils_SOURCE_DIR}")

# include(xper_utils)
# include(add_copy_dir_dependency)
# include(fetch_stb)
```