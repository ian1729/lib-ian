function(ian_enable_sanitizers target)
  if(NOT
     CMAKE_CXX_COMPILER_ID
     MATCHES
     ".*Clang")
    if(IAN_ENABLE_SANITIZER_ADDRESS
       OR IAN_ENABLE_SANITIZER_UNDEFINED
       OR IAN_ENABLE_SANITIZER_THREAD)
      message(
        FATAL_ERROR
          "Sanitizers were requested, but compiler is unsupported: ${CMAKE_CXX_COMPILER_ID}"
      )
    endif()
    return()
  endif()

  set(sanitizer_list "")

  if(IAN_ENABLE_SANITIZER_ADDRESS)
    list(APPEND sanitizer_list "address")
  endif()

  if(IAN_ENABLE_SANITIZER_UNDEFINED)
    list(
      APPEND
      sanitizer_list
      "undefined"
      "implicit-conversion"
      "nullability"
      "local-bounds")
  endif()

  if(IAN_ENABLE_SANITIZER_THREAD)
    if("address" IN_LIST sanitizer_list)
      message(
        FATAL_ERROR
          "TSan is incompatible with ASan; enable only one of IAN_ENABLE_SANITIZER_THREAD or IAN_ENABLE_SANITIZER_ADDRESS"
      )
    else()
      list(APPEND sanitizer_list "thread")
    endif()
  endif()

  list(
    JOIN
    sanitizer_list
    ","
    sanitizer_flags)
  if(sanitizer_flags)
    target_compile_options(
      ${target}
      INTERFACE -O1
                -fno-optimize-sibling-calls
                -fsanitize=${sanitizer_flags}
                -fno-omit-frame-pointer
                -fno-sanitize-recover=all)
    target_link_options(${target} INTERFACE -fsanitize=${sanitizer_flags})
  endif()
endfunction()
