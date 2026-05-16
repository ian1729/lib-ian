#!/usr/bin/env python3
import re
import sys
import pathlib


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <component-name>", file=sys.stderr)
        sys.exit(1)

    name = sys.argv[1]

    if not re.fullmatch(r"[a-z][a-z0-9_]*", name):
        print(
            "error: name must start with a letter and contain only lowercase letters, digits, and underscores",
            file=sys.stderr,
        )
        sys.exit(1)

    targets = [
        pathlib.Path(f"include/ian/{name}.hpp"),
        pathlib.Path(f"test/{name}.test.cpp"),
        pathlib.Path(f"app/{name}.app.cpp"),
    ]

    for t in targets:
        if t.exists():
            print(f"error: {t} already exists", file=sys.stderr)
            sys.exit(1)

    components = pathlib.Path("ian-components.cmake")
    lines = components.read_text().splitlines(keepends=True)
    close = next(i for i, l in enumerate(lines) if l.strip() == ")")
    lines.insert(close, f"  {name}\n")
    components.write_text("".join(lines))

    targets[0].write_text(
        f"#pragma once\n"
        f"\n"
        f"namespace ian::{name} {{\n"
        f"\n"
        f"}} // namespace ian::{name}\n"
    )

    targets[1].write_text(
        f'#include <catch2/catch_test_macros.hpp>\n'
        f"\n"
        f"#include <ian/{name}.hpp>  // NOLINT(misc-include-cleaner)\n"
        f"\n"
        f'TEST_CASE("placeholder", "[{name}]") {{}}\n'
    )

    targets[2].write_text(
        f"#include <cstdio>\n"
        f"#include <ian/{name}.hpp>  // NOLINT(misc-include-cleaner)\n"
        f"\n"
        f"int main() {{\n"
        f'  std::puts("ian::{name} example");\n'
        f"  return 0;\n"
        f"}}\n"
    )

    print(f"ian::{name} created; re-run cmake to pick up new targets")


if __name__ == "__main__":
    main()
