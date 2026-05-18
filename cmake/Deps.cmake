include(FetchContent)

FetchContent_Declare(
    dbg_macro
    GIT_REPOSITORY https://github.com/sharkdp/dbg-macro.git
    GIT_TAG        v0.5.1
    SYSTEM)

FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG        v1.17.0
    SYSTEM)

FetchContent_Declare(
    backward
    GIT_REPOSITORY https://github.com/bombela/backward-cpp.git
    GIT_TAG        v1.6
    SYSTEM)

FetchContent_MakeAvailable(dbg_macro spdlog backward)
