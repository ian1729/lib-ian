function(ian_add_component name)
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

  set_target_properties(ian_${name} PROPERTIES EXPORT_NAME ${name} VERIFY_INTERFACE_HEADER_SETS ${PROJECT_IS_TOP_LEVEL})
endfunction()

function(ian_install_component name)
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
  configure_package_config_file(cmake/ian-component-config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config.cmake
                                INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-${name}/cmake)

  write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/ian-${name}-config-version.cmake
          DESTINATION ${CMAKE_INSTALL_DATADIR}/ian-${name}/cmake)
endfunction()
