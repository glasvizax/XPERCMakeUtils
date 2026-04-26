# XPERCMakeUtils

My custom cmake utils library

## For download library through cmake:

```cmake
include(FetchContent)
FetchContent_Declare(
    XPERCMakeUtils
    GIT_REPOSITORY https://github.com/glasvizax/XPERCMakeUtils
    GIT_TAG v1.3
    SYSTEM
)

FetchContent_MakeAvailable(XPERCMakeUtils)

list(APPEND CMAKE_MODULE_PATH "${XPERCMakeUtils_SOURCE_DIR}")

# include(add_copy_dir_dependency)
# include(fetch_stb)
# include(add_libraries_to_folder)
```

## FetchContent adds a target 'XPERCMakeUtils' that includes all *.cmake files containing functions, improving the readability and accessibility of documentation for each function within IDEs.