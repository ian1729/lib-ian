function(ian_prevent_in_source_builds)
  file(REAL_PATH "${CMAKE_SOURCE_DIR}" srcdir)
  file(REAL_PATH "${CMAKE_BINARY_DIR}" bindir)
  if("${srcdir}" STREQUAL "${bindir}")
    message(
      FATAL_ERROR
        "In-source builds are not allowed. Create a build directory and run cmake from there."
    )
  endif()
endfunction()

ian_prevent_in_source_builds()
