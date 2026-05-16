cmake_minimum_required(VERSION 3.20)
project(ian-lib VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(IAN_BUILD_TESTS "Build tests" ON)
option(IAN_BUILD_APPS  "Build example apps" ON)

# ian::net — header-only networking library
add_library(ian_net INTERFACE)
add_library(ian::net ALIAS ian_net)

target_include_directories(ian_net INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if(IAN_BUILD_TESTS)
    enable_testing()

    add_executable(ian_net_test
        test/net.test.cpp
    )

    target_link_libraries(ian_net_test
        PRIVATE
            ian::net
    )

    add_test(NAME ian_net_test COMMAND ian_net_test)
endif()

if(IAN_BUILD_APPS)
    add_executable(ian_net_example_app
        app/net_example.app.cpp
    )

    target_link_libraries(ian_net_example_app
        PRIVATE
            ian::net
    )
endif()
