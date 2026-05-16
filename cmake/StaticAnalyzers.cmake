function(ian_enable_clang_tidy warnings_as_errors)
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

  if(APPLE)
    execute_process(
      COMMAND xcrun --show-sdk-path
      OUTPUT_VARIABLE IAN_APPLE_SDK_PATH
      OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if(IAN_APPLE_SDK_PATH)
      list(
        APPEND
        clang_tidy_cmd
        --extra-arg=-isysroot
        --extra-arg=${IAN_APPLE_SDK_PATH})
    endif()
  endif()

  if(warnings_as_errors)
    list(APPEND clang_tidy_cmd -warnings-as-errors=*)
  endif()

  set(CMAKE_CXX_CLANG_TIDY
      "${clang_tidy_cmd}"
      PARENT_SCOPE)
endfunction()
