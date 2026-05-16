# Compiler warning configuration for Clang.
# Based on: https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md

function(ian_set_warnings target_name warnings_as_errors)
  set(clang_warnings
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
    list(APPEND clang_warnings -Werror)
  endif()

  target_compile_options(${target_name} INTERFACE $<$<COMPILE_LANGUAGE:CXX>:${clang_warnings}>)
endfunction()
