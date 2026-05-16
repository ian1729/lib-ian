function(ian_enable_sanitizers target)
  if(NOT (CMAKE_CXX_COMPILER_ID MATCHES ".*Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
    return()
  endif()

  set(sanitizer_list "")

  if(IAN_ENABLE_SANITIZER_ADDRESS)
    list(APPEND sanitizer_list "address")
  endif()

  if(IAN_ENABLE_SANITIZER_UNDEFINED)
    list(APPEND sanitizer_list "undefined")
    if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
      list(
        APPEND
        sanitizer_list
        "implicit-conversion"
        "nullability"
        "local-bounds")
    endif()
  endif()

  if(IAN_ENABLE_SANITIZER_THREAD)
    if("address" IN_LIST sanitizer_list)
      message(WARNING "TSan is incompatible with ASan; skipping thread sanitizer")
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
