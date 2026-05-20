function(ian_define_component_impl name)
  set(links ${ARGN})

  add_library(ian_${name} INTERFACE)
  add_library(ian::${name} ALIAS ian_${name})

  target_sources(
    ian_${name}
    PUBLIC FILE_SET
           HEADERS
           BASE_DIRS
           include
           FILES
           include/ian/${name}.hpp)

  target_compile_features(ian_${name} INTERFACE cxx_std_23)

  set_target_properties(
    ian_${name} PROPERTIES EXPORT_NAME ${name} VERIFY_INTERFACE_HEADER_SETS
                                               ${PROJECT_IS_TOP_LEVEL})

  foreach(link IN LISTS links)
    target_link_libraries(ian_${name} INTERFACE ${link})
  endforeach()

  target_link_libraries(ian_${name} INTERFACE dbg_macro
                                              spdlog::spdlog_header_only)

  set(_pch
      <dbg.h>
      <spdlog/spdlog.h>
      <string>
      <vector>
      <memory>
      <sys/socket.h>
      <netinet/in.h>
      <netdb.h>)

  if(IAN_BUILD_TESTS)
    add_executable(ian_${name}_test test/${name}.test.cpp)
    target_sources(ian_${name}_test PRIVATE ${BACKWARD_ENABLE})
    target_link_libraries(
      ian_${name}_test
      PRIVATE ian::${name}
              ian_warnings
              ian_options
              Catch2::Catch2WithMain)
    add_backward(ian_${name}_test)
    target_include_directories(ian_${name}_test SYSTEM
                               PRIVATE ${backward_SOURCE_DIR})
    target_precompile_headers(
      ian_${name}_test
      PRIVATE
      ${_pch}
      <catch2/catch_test_macros.hpp>)
    catch_discover_tests(ian_${name}_test)
  endif()

  if(IAN_BUILD_APPS)
    add_executable(ian_${name}_app app/${name}.app.cpp)
    target_sources(ian_${name}_app PRIVATE ${BACKWARD_ENABLE})
    target_link_libraries(ian_${name}_app PRIVATE ian::${name} ian_warnings
                                                  ian_options)
    add_backward(ian_${name}_app)
    target_include_directories(ian_${name}_app SYSTEM
                               PRIVATE ${backward_SOURCE_DIR})
    target_precompile_headers(ian_${name}_app PRIVATE ${_pch})
  endif()

  if(IAN_ENABLE_INSTALL)
    install(
      TARGETS ian_${name}
      EXPORT ian_${name}-targets
      FILE_SET HEADERS
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

    install(
      EXPORT ian_${name}-targets
      NAMESPACE ian::
      DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-${name}/cmake)

    set(IAN_COMPONENT ${name})
    configure_package_config_file(
      cmake/ian-component-config.cmake.in
      ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config.cmake
      INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-${name}/cmake)

    write_basic_package_version_file(
      ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config-version.cmake
      VERSION ${PROJECT_VERSION}
      COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config.cmake
                  ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config-version.cmake
            DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-${name}/cmake)
  endif()
endfunction()

function(ian_declare_components)
  set(name)
  set(links)
  set(want_link OFF)

  foreach(arg IN LISTS ARGN)
    if(arg STREQUAL "LINK")
      set(want_link ON)
    elseif(want_link)
      list(APPEND links ${arg})
    else()
      if(name)
        ian_define_component_impl(${name} ${links})
      endif()
      set(name ${arg})
      set(links)
      set(want_link OFF)
    endif()
  endforeach()

  if(name)
    ian_define_component_impl(${name} ${links})
  endif()
endfunction()
