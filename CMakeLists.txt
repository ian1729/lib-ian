cmake_minimum_required(VERSION 3.29...4.3)

project(
  ian
  VERSION 0.1.0
  LANGUAGES CXX)

if(NOT
   CMAKE_CXX_COMPILER_ID
   MATCHES
   ".*Clang")
  message(FATAL_ERROR "Only Clang is supported. Detected compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

if(PROJECT_IS_TOP_LEVEL)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
  include(cmake/PreventInSourceBuilds.cmake)
endif()

option(IAN_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)
option(IAN_BUILD_TESTS "Build tests" ${PROJECT_IS_TOP_LEVEL})
option(IAN_BUILD_APPS "Build example apps" ${PROJECT_IS_TOP_LEVEL})

if(PROJECT_IS_TOP_LEVEL)
  option(IAN_ENABLE_CLANG_TIDY "Enable clang-tidy static analysis" OFF)
  option(IAN_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
  option(IAN_ENABLE_SANITIZER_UNDEFINED "Enable undefined behavior sanitizer" OFF)
  option(IAN_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
endif()

include(cmake/CompilerWarnings.cmake)
include(cmake/ComponentHelpers.cmake)
include(ian-components.cmake)

foreach(component IN LISTS ian_components)
  ian_add_component(${component})
endforeach()

add_library(ian_warnings INTERFACE)
ian_set_warnings(ian_warnings ${IAN_WARNINGS_AS_ERRORS})

add_library(ian_options INTERFACE)

if(PROJECT_IS_TOP_LEVEL)
  include(cmake/Sanitizers.cmake)
  include(cmake/StaticAnalyzers.cmake)

  ian_enable_sanitizers(ian_options)
endif()

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

  foreach(component IN LISTS ian_components)
    add_executable(ian_${component}_test test/${component}.test.cpp)
    target_link_libraries(
      ian_${component}_test
      PRIVATE ian::${component}
              ian_warnings
              ian_options
              Catch2::Catch2WithMain)
    catch_discover_tests(ian_${component}_test)
  endforeach()
endif()

if(IAN_BUILD_APPS)
  foreach(component IN LISTS ian_components)
    add_executable(ian_${component}_app app/${component}.app.cpp)
    target_link_libraries(ian_${component}_app PRIVATE ian::${component} ian_warnings ian_options)
  endforeach()
endif()

if(NOT CMAKE_SKIP_INSTALL_RULES)
  include(CMakePackageConfigHelpers)

  if(NOT DEFINED CMAKE_INSTALL_INCLUDEDIR)
    set(CMAKE_INSTALL_INCLUDEDIR "include")
  endif()
  if(NOT DEFINED CMAKE_INSTALL_DATADIR)
    set(CMAKE_INSTALL_DATADIR "share")
  endif()

  foreach(component IN LISTS ian_components)
    ian_install_component(${component})
  endforeach()
endif()
