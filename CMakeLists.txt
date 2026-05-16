cmake_minimum_required(VERSION 3.29...4.3)

project(
  ian-lib
  VERSION 0.1.0
  LANGUAGES CXX)

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

add_library(ian_net INTERFACE)
add_library(ian::net ALIAS ian_net)

target_sources(
  ian_net
  PUBLIC FILE_SET
         HEADERS
         BASE_DIRS
         include
         FILES
         include/ian/net.hpp)

target_compile_features(ian_net INTERFACE cxx_std_23)

set_target_properties(ian_net PROPERTIES EXPORT_NAME net VERIFY_INTERFACE_HEADER_SETS ${PROJECT_IS_TOP_LEVEL})

add_library(ian_warnings INTERFACE)
ian_set_warnings(ian_warnings ${IAN_WARNINGS_AS_ERRORS})

add_library(ian_options INTERFACE)

if(PROJECT_IS_TOP_LEVEL)
  include(cmake/Sanitizers.cmake)
  include(cmake/StaticAnalyzers.cmake)

  ian_enable_sanitizers(ian_options)

  if(IAN_ENABLE_CLANG_TIDY)
    ian_enable_clang_tidy(ian_net ${IAN_WARNINGS_AS_ERRORS})
  endif()
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

  enable_testing()
  include(Catch)

  add_executable(ian_net_test test/net.test.cpp)
  target_link_libraries(
    ian_net_test
    PRIVATE ian::net
            ian_warnings
            ian_options
            Catch2::Catch2WithMain)
  catch_discover_tests(ian_net_test)
endif()

if(IAN_BUILD_APPS)
  add_executable(ian_net_app app/net.app.cpp)
  target_link_libraries(ian_net_app PRIVATE ian::net ian_warnings ian_options)
endif()

if(NOT CMAKE_SKIP_INSTALL_RULES)
  include(CMakePackageConfigHelpers)
  include(GNUInstallDirs)

  install(
    TARGETS ian_net
    EXPORT ian_net-targets
    FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

  install(
    EXPORT ian_net-targets
    NAMESPACE ian::
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-net/cmake)

  configure_package_config_file(cmake/ian-net-config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/ian-net-config.cmake
                                INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-net/cmake)

  write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/ian-net-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ian-net-config.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/ian-net-config-version.cmake
          DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-net/cmake)
endif()
