# Header library code does not perform dynamic allocation

`ian::net` is performance-oriented and header-only, so code under `include/ian/` must not perform dynamic allocation. It may use caller-provided buffers and own OS resources such as socket file descriptors, but it must not allocate from the C++ free store, C allocation APIs, or allocator-backed standard library types. Tests and examples may allocate; no-allocation tests should guard representative library operations where practical.
