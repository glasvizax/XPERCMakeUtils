# XPERCMakeUtils

My custom cmake utils library

## For download library through cmake:

```cmake
include(FetchContent)
FetchContent_Declare(
    XPERCMakeUtils
    GIT_REPOSITORY https://github.com/glasvizax/XPERCMakeUtils
    GIT_TAG v1.5
    SYSTEM
)

FetchContent_MakeAvailable(XPERCMakeUtils)

# include(add_copy_dir_dependency)
# include(fetch_stb)
# include(prepend_folder_to_targets)

# add_copy_dir_dependency(...)
# fetch_stb(...)
# prepend_folder_to_targets(...)

```

FetchContent adds a target 'XPERCMakeUtils' that includes all *.cmake files containing functions, improving the readability and accessibility of documentation for each function within IDEs.