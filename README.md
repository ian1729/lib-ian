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

```sh
# Configure + build (fast debug, clangd source)
cmake --preset dev && cmake --build --preset dev

# Run tests
ctest --preset dev

# Pre-push quality gate
cmake --preset check && cmake --build --preset check && ctest --preset check

# Thread sanitizer
cmake --preset tsan && cmake --build --preset tsan && ctest --preset tsan

# Release
cmake --preset release && cmake --build --preset release
```

## Current Status

Building out networking libraries by following Beej's Guide to Network
I'm going through <https://beej.us/guide/bgnet/html/>.

## TODO

[] Explore raw IPs in an app (ch 3 structs, ch 5 socket C)
[] Explore hostname resolution in an app (ch 5, ch 7)
[] Explore send + recv in an app (full HTTP exchange ch 7)
