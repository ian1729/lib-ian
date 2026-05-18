#pragma once

#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <string>
#include <vector>

namespace ian::socket {

struct Address {
  std::string host;
  std::uint16_t port{};
};

class Socket {
public:
  Socket();

  auto connect(Address socket_address) -> void;

  auto send(std::span<const std::byte> data, int flags = 0) -> std::size_t;

  auto sendall(std::span<const std::byte> data, int flags = 0) -> void;

  auto recv(std::size_t bufsize, int flags = 0) -> std::vector<std::byte>;

  auto close() -> void;
};

auto create_connection(
  Address socket_address,
  std::optional<double> timeout = std::nullopt,
  std::optional<Address> source_address = std::nullopt,
  bool all_errors = false
) -> Socket;

}// namespace ian::socket
