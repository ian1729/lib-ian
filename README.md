# lib-ian

My personal C++ libs.

## Rules

1. Use MissingIncludes: Strict.
2. For Public headers (in `include/ian/`):
  - Should:
    - Have a corresponding detail header file in `include/ian/detail/`
    - Have a corresponding detail namespace containing private code.
    - Have a corresponding app source file in `app/` demonstrating the public interface.
    - Have a corresponding test source file in `test/` testing the public interface.
  - Should not:
    - Use C headers.
    - Use C compatibility headers.
    - Use third party library headers.
    - Should not use macros.
  - Exception:
    - `dbg.h` and `spdlog` may be used anywhere for development experience.
    - The macro rule does not apply to `dbg(...)` or `spdlog` logging macros.
    - `backward-cpp` is linked into local apps and tests for crash traces, but
      is not part of the public library interface.
3. Detail operations under detail::ops are the only detail functions intended to be called by the public interface. They are stateless, [[nodiscard]], noexcept and return std::expected<T, Error>.
4. Helpers under detail::internal are implementation details for detail::ops and are not called by public API code.
5. No cyclic includes.
6. Be lightweight and easy to maintain. Every line of code earns its place. This isn't a library for public consumption, it's for my convenience and to wrap more complex interfaces into something easier to work with and remember.


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

Building out socket library by first learning and wrapping sockets.
I'm going through <https://beej.us/guide/bgnet/html/>.

## TODO

[] enforce rules with cmake (separate library.ops.hpp and library.internal.hpp?)


[] Connect to raw ip (ch 3 structs, ch 5 socket c)
[] Connect by hostname (ch 5, ch 7)
[] Send + recv (full http exchange ch 7)
