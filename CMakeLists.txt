cmake_minimum_required(VERSION 3.29...4.3)

project(
    ian
    VERSION 0.1.0
    LANGUAGES CXX)

include(cmake/TopLevelInit.cmake)

option(IAN_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)
option(IAN_BUILD_TESTS "Build tests" ${PROJECT_IS_TOP_LEVEL})
option(IAN_BUILD_APPS "Build example apps" ${PROJECT_IS_TOP_LEVEL})

if(PROJECT_IS_TOP_LEVEL)
    option(IAN_ENABLE_CLANG_TIDY "Enable clang-tidy static analysis" OFF)
    option(IAN_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(IAN_ENABLE_SANITIZER_UNDEFINED "Enable undefined behavior sanitizer" OFF)
    option(IAN_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(IAN_ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)
endif()

set(CMAKE_SKIP_INSTALL_RULES YES)
include(cmake/Deps.cmake)
include(cmake/InstallSetup.cmake)
include(cmake/CompilerWarnings.cmake)
include(cmake/TestInfra.cmake)
include(cmake/ComponentHelpers.cmake)

ian_declare_components(core)
ian_declare_components(socket)

add_library(ian_warnings INTERFACE)
ian_set_warnings(ian_warnings ${IAN_WARNINGS_AS_ERRORS})

add_library(ian_options INTERFACE)
ian_enable_sanitizers(ian_options)
ian_enable_coverage(ian_options)
