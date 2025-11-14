#!/usr/bin/env python3
import argparse
import os
import sys
from pathlib import Path
from typing import Tuple

DEFAULT_VERSION_FILE = Path("version")
DEFAULT_OUTPUT_FILE = Path("src/version.cmake")


def parse_version(text: str) -> Tuple[int, int, int]:
    parts = text.strip().split(".")
    if not parts or len(parts) > 3:
        raise ValueError(f"Invalid version string: '{text.strip()}'")
    while len(parts) < 3:
        parts.append("0")
    try:
        major, minor, patch = (int(part) for part in parts[:3])
    except ValueError as exc:
        raise ValueError(f"Version '{text.strip()}' must contain integers.") from exc
    return major, minor, patch


def load_semver(path: Path) -> Tuple[int, int, int]:
    return parse_version(path.read_text(encoding="utf-8"))


def format_semver(major: int, minor: int, patch: int) -> str:
    return f"{major}.{minor}.{patch}"


def render_version_cmake(major: int, minor: int, patch: int) -> str:
    return (
        f"set(ABCMAKE_VERSION_MAJOR {major})\n"
        f"set(ABCMAKE_VERSION_MINOR {minor})\n"
        f"set(ABCMAKE_VERSION_PATCH {patch})\n"
        f"set(ABCMAKE_VERSION \"${{ABCMAKE_VERSION_MAJOR}}.${{ABCMAKE_VERSION_MINOR}}.${{ABCMAKE_VERSION_PATCH}}\")\n"
    )


def write_output(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def check_output(path: Path, expected: str) -> int:
    if not path.exists():
        print(f"❌ {path} is missing (check failed)")
        return 1
    if path.read_text(encoding="utf-8") != expected:
        print(f"❌ {path} is out of date.")
        print("   Run: python scripts/generate_version.py")
        return 2
    print(f"✅ {path} is up to date.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate src/version.cmake from version file.")
    parser.add_argument("--version-file", type=Path, default=DEFAULT_VERSION_FILE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_FILE)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    os.chdir(Path(__file__).resolve().parent.parent)
    major, minor, patch = load_semver(args.version_file)
    rendered = render_version_cmake(major, minor, patch)

    if args.check:
        return check_output(args.output, rendered)

    write_output(args.output, rendered)
    print(f"✅ Generated {args.output} for version {major}.{minor}.{patch}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
