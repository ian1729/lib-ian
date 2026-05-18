#include <ian/net.hpp>

#include <catch2/catch_test_macros.hpp>

#include <array>
#include <concepts>
#include <cstdint>
#include <string>
#include <system_error>
#include <type_traits>
#include <utility>
#include <vector>

namespace {

using ian::net::HostPort;
using ian::net::IpAddr;
using ian::net::Ipv4Addr;
using ian::net::Ipv6Addr;
using ian::net::SocketAddr;
using ian::net::SocketAddrV4;
using ian::net::SocketAddrV6;

static_assert(std::is_constructible_v<
  Ipv4Addr,
  std::uint8_t,
  std::uint8_t,
  std::uint8_t,
  std::uint8_t
>);

static_assert(std::is_constructible_v<
  Ipv6Addr,
  std::uint16_t,
  std::uint16_t,
  std::uint16_t,
  std::uint16_t,
  std::uint16_t,
  std::uint16_t,
  std::uint16_t,
  std::uint16_t
>);

static_assert(std::is_constructible_v<IpAddr, Ipv4Addr>);
static_assert(std::is_constructible_v<IpAddr, Ipv6Addr>);
static_assert(std::is_constructible_v<SocketAddr, SocketAddrV4>);
static_assert(std::is_constructible_v<SocketAddr, SocketAddrV6>);
static_assert(ian::net::ToSocketAddrs<SocketAddr>);
static_assert(ian::net::ToSocketAddrs<HostPort>);
static_assert(!ian::net::ToSocketAddrs<std::string>);

using FromSocketAddr =
  decltype(ian::net::to_socket_addrs(std::declval<SocketAddr>()));

using FromHostPort =
  decltype(ian::net::to_socket_addrs(std::declval<const HostPort&>()));

static_assert(std::same_as<
  typename FromSocketAddr::value_type,
  std::vector<SocketAddr>
>);

static_assert(std::same_as<
  typename FromSocketAddr::error_type,
  std::error_code
>);

static_assert(std::same_as<
  typename FromHostPort::value_type,
  std::vector<SocketAddr>
>);

static_assert(std::same_as<
  typename FromHostPort::error_type,
  std::error_code
>);

}

TEST_CASE("net address values expose the modeled core interaction", "[net]") {
  auto ipv4 = Ipv4Addr{127, 0, 0, 1};
  auto socket = SocketAddr{SocketAddrV4{ipv4, 8080}};

  REQUIRE(socket.is_ipv4());
  REQUIRE(socket.as_ipv4() != nullptr);

  CHECK(socket.is_ipv6() == false);
  CHECK(socket.port() == 8080);
  CHECK(socket.ip().is_ipv4());
  CHECK(socket.as_ipv4()->ip().octets() ==
        (std::array<std::uint8_t, 4>{127, 0, 0, 1}));

  socket.set_port(9000);

  CHECK(socket.port() == 9000);
}
