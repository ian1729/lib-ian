if(NOT
   CMAKE_CXX_COMPILER_ID
   MATCHES
   ".*Clang")
  message(
    FATAL_ERROR
      "Only Clang is supported. Detected compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

if(PROJECT_IS_TOP_LEVEL)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
  file(
    CREATE_LINK
    "${CMAKE_BINARY_DIR}/compile_commands.json"
    "${CMAKE_SOURCE_DIR}/compile_commands.json"
    SYMBOLIC)
  set(CMAKE_CXX_EXTENSIONS OFF)
  include(cmake/PreventInSourceBuilds.cmake)
endif()

add_compile_options(-stdlib=libc++)
add_link_options(-stdlib=libc++ -fuse-ld=lld -rtlib=compiler-rt)

include(cmake/Sanitizers.cmake)
include(cmake/Coverage.cmake)
include(cmake/StaticAnalyzers.cmake)
