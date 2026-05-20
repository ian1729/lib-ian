#include <cstdlib>
#include <dbg.h>
#include <spdlog/spdlog.h>

#include <cstdio>
#include <exception>
#include <netdb.h>
#include <ostream>
#include <sys/socket.h>

struct Wow {
  int field{};
  int field2{};
};

inline std::ostream &operator<<(std::ostream &os, const Wow &v) {
  return os << "Wow{" << "field=" << v.field << ", " << "field2=" << v.field2
            << "}";
}

int main() {

  try {
    spdlog::info("socket app started");
    dbg("testing");
    dbg(1 + 2);
    dbg(Wow{});

    int fd = socket(AF_INET, SOCK_STREAM, 0); // NOLINT(misc-include-cleaner)
    dbg(fd);

    addrinfo hints{};
    hints.ai_family = AF_UNSPEC; // NOLINT(misc-include-cleaner)
    hints.ai_socktype = SOCK_STREAM;
    addrinfo *res = nullptr;
    const int rc = getaddrinfo("localhost", "8080", &hints, &res);
    dbg(rc);
    if (rc == 0) {
      dbg(res->ai_family);
      freeaddrinfo(res);
    }

    std::abort();
  } catch (const std::exception &ex) {
    static_cast<void>(std::fputs(ex.what(), stderr));
    return 1;
  }
}
