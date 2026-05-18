if(IAN_BUILD_TESTS)
    include(FetchContent)
    FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG v3.7.1
        SYSTEM FIND_PACKAGE_ARGS 3)
    FetchContent_MakeAvailable(Catch2)
    list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)

    if(PROJECT_IS_TOP_LEVEL AND IAN_ENABLE_CLANG_TIDY)
        ian_enable_clang_tidy(${IAN_WARNINGS_AS_ERRORS})
    endif()

    enable_testing()
    include(Catch)
endif()
