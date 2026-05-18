#pragma once

#include <array>
#include <concepts>
#include <cstdint>
#include <expected>
#include <string>
#include <system_error>
#include <type_traits>
#include <variant>
#include <vector>

namespace ian::net {

class Ipv4Addr {
public:
  constexpr Ipv4Addr(
    std::uint8_t first,
    std::uint8_t second,
    std::uint8_t third,
    std::uint8_t fourth
  ) noexcept
    : octets_{first, second, third, fourth} {
  }

  [[nodiscard]] constexpr auto octets() const noexcept
    -> std::array<std::uint8_t, 4> {
    return octets_;
  }

private:
  std::array<std::uint8_t, 4> octets_{};
};

class Ipv6Addr {
public:
  constexpr Ipv6Addr(
    std::uint16_t first,
    std::uint16_t second,
    std::uint16_t third,
    std::uint16_t fourth,
    std::uint16_t fifth,
    std::uint16_t sixth,
    std::uint16_t seventh,
    std::uint16_t eighth
  ) noexcept
    : segments_{
        first,
        second,
        third,
        fourth,
        fifth,
        sixth,
        seventh,
        eighth
      } {
  }

  [[nodiscard]] constexpr auto segments() const noexcept
    -> std::array<std::uint16_t, 8> {
    return segments_;
  }

private:
  std::array<std::uint16_t, 8> segments_{};
};

class IpAddr {
public:
  explicit constexpr IpAddr(Ipv4Addr address) noexcept
    : address_{address} {
  }

  explicit constexpr IpAddr(Ipv6Addr address) noexcept
    : address_{address} {
  }

  [[nodiscard]] constexpr auto is_ipv4() const noexcept -> bool {
    return std::holds_alternative<Ipv4Addr>(address_);
  }

  [[nodiscard]] constexpr auto is_ipv6() const noexcept -> bool {
    return std::holds_alternative<Ipv6Addr>(address_);
  }

  [[nodiscard]] constexpr auto as_ipv4() const noexcept -> const Ipv4Addr* {
    return std::get_if<Ipv4Addr>(&address_);
  }

  [[nodiscard]] constexpr auto as_ipv6() const noexcept -> const Ipv6Addr* {
    return std::get_if<Ipv6Addr>(&address_);
  }

private:
  std::variant<Ipv4Addr, Ipv6Addr> address_;
};

class SocketAddrV4 {
public:
  constexpr SocketAddrV4(Ipv4Addr ip, std::uint16_t port) noexcept
    : ip_{ip},
      port_{port} {
  }

  [[nodiscard]] constexpr auto ip() const noexcept -> Ipv4Addr {
    return ip_;
  }

  constexpr auto set_ip(Ipv4Addr ip) noexcept -> void {
    ip_ = ip;
  }

  [[nodiscard]] constexpr auto port() const noexcept -> std::uint16_t {
    return port_;
  }

  constexpr auto set_port(std::uint16_t port) noexcept -> void {
    port_ = port;
  }

private:
  Ipv4Addr ip_;
  std::uint16_t port_{};
};

class SocketAddrV6 {
public:
  struct Options {
    std::uint32_t flowinfo{};
    std::uint32_t scope_id{};
  };

  constexpr SocketAddrV6(
    Ipv6Addr ip,
    std::uint16_t port,
    Options options
  ) noexcept
    : ip_{ip},
      port_{port},
      flowinfo_{options.flowinfo},
      scope_id_{options.scope_id} {
  }

  [[nodiscard]] constexpr auto ip() const noexcept -> Ipv6Addr {
    return ip_;
  }

  constexpr auto set_ip(Ipv6Addr ip) noexcept -> void {
    ip_ = ip;
  }

  [[nodiscard]] constexpr auto port() const noexcept -> std::uint16_t {
    return port_;
  }

  constexpr auto set_port(std::uint16_t port) noexcept -> void {
    port_ = port;
  }

  [[nodiscard]] constexpr auto flowinfo() const noexcept -> std::uint32_t {
    return flowinfo_;
  }

  constexpr auto set_flowinfo(std::uint32_t flowinfo) noexcept -> void {
    flowinfo_ = flowinfo;
  }

  [[nodiscard]] constexpr auto scope_id() const noexcept -> std::uint32_t {
    return scope_id_;
  }

  constexpr auto set_scope_id(std::uint32_t scope_id) noexcept -> void {
    scope_id_ = scope_id;
  }

private:
  Ipv6Addr ip_;
  std::uint16_t port_{};
  std::uint32_t flowinfo_{};
  std::uint32_t scope_id_{};
};

class SocketAddr {
public:
  explicit constexpr SocketAddr(SocketAddrV4 address) noexcept
    : address_{address} {
  }

  explicit constexpr SocketAddr(SocketAddrV6 address) noexcept
    : address_{address} {
  }

  [[nodiscard]] constexpr auto is_ipv4() const noexcept -> bool {
    return std::holds_alternative<SocketAddrV4>(address_);
  }

  [[nodiscard]] constexpr auto is_ipv6() const noexcept -> bool {
    return std::holds_alternative<SocketAddrV6>(address_);
  }

  [[nodiscard]] constexpr auto as_ipv4() const noexcept
    -> const SocketAddrV4* {
    return std::get_if<SocketAddrV4>(&address_);
  }

  [[nodiscard]] constexpr auto as_ipv6() const noexcept
    -> const SocketAddrV6* {
    return std::get_if<SocketAddrV6>(&address_);
  }

  [[nodiscard]] constexpr auto ip() const noexcept -> IpAddr {
    if (const auto* address = as_ipv4()) {
      return IpAddr{address->ip()};
    }

    return IpAddr{as_ipv6()->ip()};
  }

  [[nodiscard]] constexpr auto port() const noexcept -> std::uint16_t {
    if (const auto* address = as_ipv4()) {
      return address->port();
    }

    return as_ipv6()->port();
  }

  constexpr auto set_port(std::uint16_t port) noexcept -> void {
    if (auto* address = std::get_if<SocketAddrV4>(&address_)) {
      address->set_port(port);
      return;
    }

    std::get_if<SocketAddrV6>(&address_)->set_port(port);
  }

private:
  std::variant<SocketAddrV4, SocketAddrV6> address_;
};

struct HostPort {
  std::string host;
  std::uint16_t port{};
};

template <class T>
concept ToSocketAddrs =
  std::same_as<std::remove_cvref_t<T>, SocketAddr> ||
  std::same_as<std::remove_cvref_t<T>, HostPort>;

[[nodiscard]] auto to_socket_addrs(SocketAddr address)
  -> std::expected<std::vector<SocketAddr>, std::error_code>;

[[nodiscard]] auto to_socket_addrs(const HostPort& address)
  -> std::expected<std::vector<SocketAddr>, std::error_code>;

}
