function(ian_enable_clang_tidy target warnings_as_errors)
  find_program(CLANGTIDY clang-tidy)
  if(NOT CLANGTIDY)
    message(WARNING "clang-tidy requested but executable not found")
    return()
  endif()

  set(clang_tidy_cmd
      ${CLANGTIDY}
      -extra-arg=-Wno-unknown-warning-option
      -extra-arg=-Wno-ignored-optimization-argument
      -extra-arg=-Wno-unused-command-line-argument
      -p
      ${CMAKE_BINARY_DIR})

  if(${warnings_as_errors})
    list(APPEND clang_tidy_cmd -warnings-as-errors=*)
  endif()

  set_target_properties(${target} PROPERTIES CXX_CLANG_TIDY "${clang_tidy_cmd}")
endfunction()
