include(FetchContent)

FetchContent_Declare(
  dbg_macro
  GIT_REPOSITORY https://github.com/sharkdp/dbg-macro.git
  GIT_TAG v0.5.1
  SYSTEM)

FetchContent_Declare(
  spdlog
  GIT_REPOSITORY https://github.com/gabime/spdlog.git
  GIT_TAG v1.17.0
  SYSTEM)

FetchContent_Declare(
  backward
  GIT_REPOSITORY https://github.com/bombela/backward-cpp.git
  GIT_TAG v1.6
  SYSTEM)

if(DEFINED CMAKE_WARN_DEPRECATED)
  set(IAN_WARN_DEPRECATED_WAS_DEFINED YES)
  set(IAN_WARN_DEPRECATED ${CMAKE_WARN_DEPRECATED})
else()
  set(IAN_WARN_DEPRECATED_WAS_DEFINED NO)
endif()

set(CMAKE_WARN_DEPRECATED
    OFF
    CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(dbg_macro spdlog backward)

if(IAN_WARN_DEPRECATED_WAS_DEFINED)
  set(CMAKE_WARN_DEPRECATED
      ${IAN_WARN_DEPRECATED}
      CACHE BOOL "" FORCE)
else()
  unset(CMAKE_WARN_DEPRECATED CACHE)
endif()
