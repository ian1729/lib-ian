#include <ian/net.hpp>

#include <type_traits>

auto main() -> int {
  static_assert(std::is_class_v<ian::net::Ipv4Addr>);

  return 0;
}
