cmake_minimum_required(VERSION 3.29...4.3)

project(
  ian
  VERSION 0.1.0
  LANGUAGES CXX)

include(cmake/TopLevelInit.cmake)

option(IAN_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)
option(IAN_BUILD_TESTS "Build tests" ${PROJECT_IS_TOP_LEVEL})
option(IAN_BUILD_APPS "Build example apps" ${PROJECT_IS_TOP_LEVEL})
option(IAN_ENABLE_INSTALL "Generate install rules" OFF)

if(PROJECT_IS_TOP_LEVEL)
  option(IAN_ENABLE_CLANG_TIDY "Enable clang-tidy static analysis" OFF)
  option(IAN_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
  option(IAN_ENABLE_SANITIZER_UNDEFINED "Enable undefined behavior sanitizer"
         OFF)
  option(IAN_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
  option(IAN_ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)
endif()

file(
  GLOB_RECURSE
  IAN_CXX_FORMAT_FILES
  CONFIGURE_DEPENDS
  app/*.cpp
  include/*.hpp
  test/*.cpp)

file(
  GLOB
  IAN_CMAKE_FORMAT_FILES
  CONFIGURE_DEPENDS
  CMakeLists.txt
  cmake/*.cmake)

include(cmake/Deps.cmake)
include(cmake/InstallSetup.cmake)
include(cmake/CompilerWarnings.cmake)
include(cmake/TestInfra.cmake)
include(cmake/ComponentHelpers.cmake)

ian_declare_components(socket)

add_library(ian_warnings INTERFACE)
ian_set_warnings(ian_warnings ${IAN_WARNINGS_AS_ERRORS})

add_library(ian_options INTERFACE)
ian_enable_sanitizers(ian_options)
ian_enable_coverage(ian_options)

find_program(CLANG_FORMAT clang-format)
find_program(CMAKE_FORMAT cmake-format)

if(CLANG_FORMAT AND CMAKE_FORMAT)
  add_custom_target(
    format
    COMMAND ${CLANG_FORMAT} -i ${IAN_CXX_FORMAT_FILES}
    COMMAND ${CMAKE_FORMAT} -i ${IAN_CMAKE_FORMAT_FILES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Format C++ and CMake files")

  add_custom_target(
    format-check
    COMMAND ${CLANG_FORMAT} --dry-run --Werror ${IAN_CXX_FORMAT_FILES}
    COMMAND ${CMAKE_FORMAT} --check ${IAN_CMAKE_FORMAT_FILES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Check C++ and CMake formatting")
else()
  add_custom_target(
    format
    COMMAND ${CMAKE_COMMAND} -E false
    COMMENT "clang-format and cmake-format are required")

  add_custom_target(
    format-check
    COMMAND ${CMAKE_COMMAND} -E false
    COMMENT "clang-format and cmake-format are required")
endif()
