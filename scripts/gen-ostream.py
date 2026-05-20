#!/usr/bin/env python3
"""Generate operator<< for all structs/classes in include/**/*.hpp that lack one.

Usage:
    python3 scripts/gen-ostream.py              # scan include/**/*.hpp
    python3 scripts/gen-ostream.py <file> ...   # explicit files
"""

import sys
import json
import subprocess
import shlex
from pathlib import Path

try:
    import clang.cindex as ci
except ImportError:
    sys.exit("error: sudo apt-get install python3-clang")

REPO_ROOT = Path(__file__).resolve().parent.parent


def load_db() -> list[dict]:
    db_path = REPO_ROOT / "compile_commands.json"
    if not db_path.exists():
        sys.exit("error: compile_commands.json not found — run: make build")
    return json.loads(db_path.read_text())


def extract_flags(entry: dict, source: Path) -> list[str]:
    raw = entry.get("arguments") or shlex.split(entry["command"])
    flags, skip = [], False
    for tok in raw[1:]:
        if skip:
            skip = False
            continue
        if tok in ("-o", "-MF", "-MT", "-MQ"):
            skip = True
            continue
        if tok in ("-c", "-MD", "-MMD"):
            continue
        if Path(tok).resolve() == source:
            continue
        flags.append(tok)
    return flags


def compile_flags(source: Path, db: list[dict]) -> list[str]:
    # exact match (for .cpp files)
    for entry in db:
        if Path(entry["file"]).resolve() == source:
            return extract_flags(entry, source)
    # headers: match via verify_interface_header_sets entry
    # e.g. include/ian/socket.hpp -> .../ian_socket_verify.../ian/socket.hpp.cxx
    if source.suffix == ".hpp":
        for entry in db:
            ef = entry["file"]
            if "verify_interface_header_sets" in ef and ef.endswith(f"/{source.name}.cxx"):
                entry_path = Path(entry["file"]).resolve()
                return extract_flags(entry, entry_path)
    # fallback: any app .cpp (shares the same include paths)
    for entry in db:
        if entry["file"].endswith(".cpp") and "/app/" in entry["file"]:
            return extract_flags(entry, Path(entry["file"]).resolve())
    return []


def find_all_types(tu, source: Path) -> list:
    results = []

    def walk(cursor):
        try:
            kind = cursor.kind
        except ValueError:
            return
        if (
            kind in (ci.CursorKind.STRUCT_DECL, ci.CursorKind.CLASS_DECL)
            and cursor.is_definition()
            and cursor.location.file
            and Path(cursor.location.file.name).resolve() == source
        ):
            results.append(cursor)
        for child in cursor.get_children():
            walk(child)

    walk(tu.cursor)
    return results


def has_ostream_op(tu, source: Path, type_name: str) -> bool:
    def walk(cursor):
        try:
            kind = cursor.kind
        except ValueError:
            return False
        if (
            kind == ci.CursorKind.FUNCTION_DECL
            and cursor.spelling == "operator<<"
            and cursor.location.file
            and Path(cursor.location.file.name).resolve() == source
        ):
            for param in cursor.get_arguments():
                if type_name in param.type.spelling:
                    return True
        for child in cursor.get_children():
            if walk(child):
                return True
        return False

    return walk(tu.cursor)


def public_fields(cursor) -> list[str]:
    return [
        c.spelling
        for c in cursor.get_children()
        if c.kind == ci.CursorKind.FIELD_DECL
        and c.access_specifier
        in (ci.AccessSpecifier.PUBLIC, ci.AccessSpecifier.INVALID)
    ]


def make_operator(name: str, fields: list[str]) -> str:
    if not fields:
        body = f'return os << "{name}{{}}"'
    else:
        parts = ' << ", " << '.join(f'"{f}=" << v.{f}' for f in fields)
        body = f'return os << "{name}{{" << {parts} << "}}"'
    return (
        f"\ninline std::ostream& operator<<(std::ostream& os, const {name}& v) {{\n"
        f"  {body};\n"
        f"}}\n"
    )


def ensure_ostream(lines: list[str]) -> list[str]:
    if any("<ostream>" in l or "<iostream>" in l for l in lines):
        return lines
    last_inc = next(
        (i for i in range(len(lines) - 1, -1, -1) if lines[i].strip().startswith("#include")),
        -1,
    )
    insert_at = last_inc + 1 if last_inc >= 0 else 0
    return lines[:insert_at] + ["#include <ostream>\n"] + lines[insert_at:]


def process(source: Path, db: list[dict], idx: ci.Index) -> None:
    flags = compile_flags(source, db)
    tu = idx.parse(str(source), args=flags)

    all_types = find_all_types(tu, source)
    missing = [t for t in all_types if not has_ostream_op(tu, source, t.spelling)]
    if not missing:
        return

    lines = source.read_text().splitlines(keepends=True)

    # insert bottom-to-top so earlier line numbers stay valid
    for node in sorted(missing, key=lambda c: c.extent.end.line, reverse=True):
        end_line = node.extent.end.line
        lines = lines[:end_line] + [make_operator(node.spelling, public_fields(node))] + lines[end_line:]

    lines = ensure_ostream(lines)
    source.write_text("".join(lines))
    subprocess.run(["clang-format", "-i", str(source)], check=True)

    names = ", ".join(n.spelling for n in missing)
    print(f"{source.relative_to(REPO_ROOT)}: generated operator<< for {names}")


def main() -> None:
    db = load_db()
    idx = ci.Index.create()

    if len(sys.argv) > 1:
        files = [Path(f).resolve() for f in sys.argv[1:]]
    else:
        files = sorted((REPO_ROOT / "include").rglob("*.hpp"))

    for source in files:
        process(source, db, idx)


if __name__ == "__main__":
    main()
