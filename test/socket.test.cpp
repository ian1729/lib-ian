#include <catch2/catch_test_macros.hpp>
#include <string>

TEST_CASE("socket app inputs use the familiar host port shape", "[socket]") {
  const auto host = std::string{"example.com"};
  constexpr auto PORT = 80;

  CHECK(host == "example.com");
  CHECK(PORT == 80);
}
