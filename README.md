# lib-ian

My personal C++ libs.

## Rules

1. Use `MissingIncludes: Strict`.
2. For Public headers (in `include/ian/`):
  - Should:
    - Have a corresponding detail header file in `include/ian/detail/`
    - Have a corresponding `detail` namespace containing private code.
    - Have a corresponding app source file in `app/`.
    - Have a corresponding test source file in `test/`.
3. No cyclic includes.
4. Be lightweight and easy to maintain. Every line of code earns its place.
   This isn't a library for public consumption, it's for my convenience and to
   wrap more complex interfaces into something easier to work with and
   remember.


## Workflow

Workflow presets run configure, build, and test in one command:

```sh
# Fast debug build for local iteration
cmake --workflow --preset dev

# Pre-push quality gate: sanitizers, coverage, clang-tidy, warnings as errors
cmake --workflow --preset check

# Thread sanitizer
cmake --workflow --preset tsan

# Optimized release build
cmake --workflow --preset release
```

Individual presets are also available when a single step is needed:

```sh
# Configure
cmake --preset dev
cmake --preset check
cmake --preset tsan
cmake --preset release

# Build
cmake --build --preset dev
cmake --build --preset check
cmake --build --preset tsan
cmake --build --preset release

# Format
cmake --build --preset format
cmake --build --preset format-check

# Test
ctest --preset dev
ctest --preset check
ctest --preset tsan
ctest --preset release
```

Available presets can be listed with:

```sh
cmake --list-presets
cmake --list-presets=workflow
```


## Current Status

Building out networking libraries by following Beej's Guide to Network.

## TODO

[] Explore `socket()` creation in an app (ch 5 socket C)
[] Explore `getaddrinfo()` in an app (ch 5, ch 7)
[] Explore `send()` + `recv()` in an app (full HTTP exchange ch 7)
