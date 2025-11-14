#!/usr/bin/env python3
"""Generate src/version.cmake from the plain-text version file."""
import argparse
import os
import sys
from pathlib import Path
from typing import Tuple

DEFAULT_VERSION_FILE = Path("version")
DEFAULT_OUTPUT_FILE = Path("src/version.cmake")


def build_argument_parser() -> argparse.ArgumentParser:
    """Configure CLI arguments for the script."""
    parser = argparse.ArgumentParser(
        description="Convert the repo version file into src/version.cmake.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                    # Generate src/version.cmake
  %(prog)s --check            # Verify the file is up to date
  %(prog)s --version-file foo # Use a custom version source
        """,
    )
    parser.add_argument(
        "--version-file",
        type=Path,
        default=DEFAULT_VERSION_FILE,
        help=f"Path to the plain-text version file (default: {DEFAULT_VERSION_FILE})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT_FILE,
        help=f"Path to the generated CMake file (default: {DEFAULT_OUTPUT_FILE})",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Only check whether the output file matches the version file",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enable verbose logging",
    )
    return parser


def switch_to_repo_root() -> Path:
    """Change the working directory to the repository root."""
    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parent
    os.chdir(repo_root)
    return repo_root


def read_version_file(path: Path, verbose: bool = False) -> str:
    """Read the raw version string from disk."""
    if verbose:
        print(f"Reading version from {path}")
    if not path.exists():
        raise FileNotFoundError(f"Version file not found: {path}")
    return path.read_text(encoding="utf-8")


def parse_version_string(raw: str) -> Tuple[int, int, int]:
    """Parse "major.minor.patch" into integer components."""
    cleaned = raw.strip()
    if not cleaned:
        raise ValueError("Version file is empty.")
    parts = cleaned.split(".")
    if len(parts) not in (2, 3):
        raise ValueError(
            f"Version '{cleaned}' must include two or three numeric components separated by dots."
        )
    while len(parts) < 3:
        parts.append("0")
    try:
        major, minor, patch = (int(part) for part in parts[:3])
    except ValueError as exc:
        raise ValueError(f"Version '{cleaned}' must contain only integer components.") from exc
    return major, minor, patch


def load_semver(version_path: Path, verbose: bool = False) -> Tuple[int, int, int]:
    """Return (major, minor, patch) from the version file."""
    raw_version = read_version_file(version_path, verbose)
    return parse_version_string(raw_version)


def format_semver(major: int, minor: int, patch: int) -> str:
    """Return the dotted semantic version string."""
    return f"{major}.{minor}.{patch}"


def render_version_cmake(major: int, minor: int, patch: int) -> str:
    """Return the contents of src/version.cmake for the given numbers."""
    return (
        f"set(ABCMAKE_VERSION_MAJOR {major})\n"
        f"set(ABCMAKE_VERSION_MINOR {minor})\n"
        f"set(ABCMAKE_VERSION_PATCH {patch})\n"
        f"set(ABCMAKE_VERSION \"${{ABCMAKE_VERSION_MAJOR}}.${{ABCMAKE_VERSION_MINOR}}.${{ABCMAKE_VERSION_PATCH}}\")\n"
    )


def check_version_file(output_path: Path, expected_content: str) -> int:
    """Verify that the output file already matches the desired content."""
    if not output_path.exists():
        print(f"❌ {output_path} is missing (check failed)")
        return 1
    current = output_path.read_text(encoding="utf-8")
    if current != expected_content:
        print(f"❌ {output_path} is out of date.")
        print("   Run: python scripts/generate_version.py")
        return 2
    print(f"✅ {output_path} is up to date.")
    return 0


def write_version_file(output_path: Path, content: str, verbose: bool = False) -> None:
    """Write the rendered version content to disk."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    if verbose:
        print(f"Writing version data to {output_path}")
    output_path.write_text(content, encoding="utf-8")


def run_flow(
    version_path: Path,
    output_path: Path,
    check_only: bool,
    verbose: bool = False,
) -> int:
    """Coordinate reading, parsing, and writing the version file."""
    try:
        major, minor, patch = load_semver(version_path, verbose)
        if verbose:
            print(f"Parsed version: {major}.{minor}.{patch}")
        rendered = render_version_cmake(major, minor, patch)
        if check_only:
            return check_version_file(output_path, rendered)
        write_version_file(output_path, rendered, verbose)
        print(
            f"✅ Generated {output_path} for version {major}.{minor}.{patch}"
        )
        return 0
    except Exception as exc:
        print(f"❌ Error: {exc}", file=sys.stderr)
        if verbose:
            import traceback

            traceback.print_exc()
        return 3


def main() -> int:
    args = build_argument_parser().parse_args()
    repo_root = switch_to_repo_root()
    if args.verbose:
        print(f"Repository root: {repo_root}")
    return run_flow(args.version_file, args.output, args.check, args.verbose)


if __name__ == "__main__":
    sys.exit(main())
