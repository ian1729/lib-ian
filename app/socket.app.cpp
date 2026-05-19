#include <dbg.h>
#include <spdlog/common.h>
#include <spdlog/spdlog.h>

#include <backward.hpp>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <exception>
#include <functional>
#include <string>
#include <string_view>
#include <utility>

namespace ian::socket::demo {

enum class ConnectionState : std::uint8_t { OPEN, CLOSED, PENDING };

struct Endpoint {
  std::string host;
  int port;
};

class Connection {
public:
  Connection(Endpoint endpoint, std::chrono::seconds timeout,
             bool reuse_address, std::size_t buffer_size)
      : endpoint_{std::move(endpoint)}, timeout_{timeout},
        reuse_address_{reuse_address}, buffer_size_{buffer_size} {}

  [[nodiscard]] bool isOpen() const { return state_ == ConnectionState::OPEN; }
  [[nodiscard]] std::size_t bufferSize() const { return buffer_size_; }
  [[nodiscard]] bool reuseAddress() const { return reuse_address_; }
  [[nodiscard]] std::chrono::seconds timeout() const { return timeout_; }
  [[nodiscard]] const Endpoint &endpoint() const { return endpoint_; }

  static std::string_view describe(ConnectionState state) {
    switch (state) {
    case ConnectionState::OPEN:
      return "open";
    case ConnectionState::CLOSED:
      return "closed";
    case ConnectionState::PENDING:
      return "pending";
    }
    return "unknown";
  }

  template <typename Handler> void onStateChange(Handler &&handler) {
    handler_ = std::forward<Handler>(handler);
  }

private:
  Endpoint endpoint_;
  std::chrono::seconds timeout_;                     // connect timeout
  bool reuse_address_;                               // SO_REUSEADDR
  std::size_t buffer_size_;                          // send / recv buffer
  ConnectionState state_ = ConnectionState::PENDING; // current state
  std::function<void(ConnectionState)> handler_;
};

constexpr std::size_t DEFAULT_BUFFER_SIZE = 4096;

} // namespace ian::socket::demo

int main() {
  using ian::socket::demo::Connection;
  using ian::socket::demo::ConnectionState;
  using ian::socket::demo::DEFAULT_BUFFER_SIZE;
  using ian::socket::demo::Endpoint;

  try {
    constexpr auto PORT = 80;
    constexpr auto STACK_TRACE_DEPTH = 8;
    constexpr auto TIMEOUT = std::chrono::seconds{30};

    spdlog::set_level(spdlog::level::debug);
    spdlog::info("socket app started");

    const auto *host = "example.com";

    auto connection =
        Connection{Endpoint{host, PORT}, TIMEOUT, true, DEFAULT_BUFFER_SIZE};
    connection.onStateChange(
        [](ConnectionState state) { static_cast<void>(state); });
    static_cast<void>(connection.isOpen());
    static_cast<void>(connection.bufferSize());
    static_cast<void>(connection.reuseAddress());
    static_cast<void>(connection.timeout().count());
    static_cast<void>(connection.endpoint().port);
    static_cast<void>(Connection::describe(ConnectionState::OPEN));

    dbg(host, PORT);
    spdlog::debug("prepared {}:{}", host, PORT);

    auto stack_trace = backward::StackTrace{};
    stack_trace.load_here(STACK_TRACE_DEPTH);

    auto printer = backward::Printer{};
    printer.object = true;
    printer.color_mode = backward::ColorMode::automatic;

    spdlog::info("printing a short backward-cpp stack trace");
    printer.print(stack_trace);
  } catch (const std::exception &exception) {
    static_cast<void>(std::fputs("socket app failed: ", stderr));
    static_cast<void>(std::fputs(exception.what(), stderr));
    static_cast<void>(std::fputc('\n', stderr));
    return 1;
  } catch (...) {
    static_cast<void>(
        std::fputs("socket app failed with an unknown exception\n", stderr));
    return 1;
  }

  return 0;
}
