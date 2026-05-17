# Compiler warning configuration.
# Based on: https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md

function(ian_set_warnings target_name warnings_as_errors)
  if(NOT
     CMAKE_CXX_COMPILER_ID
     MATCHES
     ".*Clang")
    message(FATAL_ERROR "Only Clang is supported. Detected compiler: ${CMAKE_CXX_COMPILER_ID}")
  endif()

  set(warnings
      -Wall
      -Wextra
      -Wshadow
      -Wnon-virtual-dtor
      -Wold-style-cast
      -Wcast-align
      -Wunused
      -Woverloaded-virtual
      -Wpedantic
      -Wconversion
      -Wnull-dereference
      -Wdouble-promotion
      -Wformat=2
      -Wimplicit-fallthrough
      -Wzero-as-null-pointer-constant
      -Wsuggest-override
      -Wextra-semi
      -Wundef)

  if(warnings_as_errors)
    list(APPEND warnings -Werror)
  endif()

  target_compile_options(${target_name} INTERFACE $<$<COMPILE_LANGUAGE:CXX>:${warnings}>)
endfunction()
