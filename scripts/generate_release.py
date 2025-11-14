#!/usr/bin/env python3
# *************************************************************************
#
# Copyright (c) 2025 Andrei Gramakov. All rights reserved.
#
# site:    https://agramakov.me
# e-mail:  mail@agramakov.me
#
# *************************************************************************
"""
Generate amalgamated release file from modular CMake source files.

This script processes the main CMake file and inlines all local includes
to create a single-file release version.
"""
import argparse
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

from generate_version import (
    DEFAULT_VERSION_FILE,
    format_semver,
    load_semver,
    render_version_cmake,
)

ABC_SRC_DIR = "src"
MAIN_FILE = "ab.cmake"
RELEASE_PATH = "release/ab.cmake"


def build_argument_parser() -> argparse.ArgumentParser:
    """Create the CLI argument parser."""
    parser = argparse.ArgumentParser(
        description="Generate amalgamated CMake release file from modular sources.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                    # Generate release file
  %(prog)s --check            # Check if release file is up to date
  %(prog)s --verbose          # Generate with verbose output
  %(prog)s --check --verbose  # Check with verbose output
        """,
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check if release file is up to date instead of generating",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Enable verbose output"
    )
    parser.add_argument(
        "--src-dir",
        type=str,
        default=ABC_SRC_DIR,
        help=f"Source directory (default: {ABC_SRC_DIR})",
    )
    parser.add_argument(
        "--main-file",
        type=str,
        default=MAIN_FILE,
        help=f"Main CMake file name (default: {MAIN_FILE})",
    )
    parser.add_argument(
        "--output",
        type=str,
        default=RELEASE_PATH,
        help=f"Output release file path (default: {RELEASE_PATH})",
    )
    parser.add_argument(
        "--version-file",
        type=Path,
        default=DEFAULT_VERSION_FILE,
        help=f"Version file to embed (default: {DEFAULT_VERSION_FILE})",
    )
    return parser


def switch_to_repo_root() -> Path:
    """Change working directory to the repository root and return the path."""
    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parent
    os.chdir(repo_root)
    return repo_root


class CMakeParseError(Exception):
    """@brief Exception raised when CMake file parsing fails."""


def read_file(file_path: Path, verbose: bool = False) -> str:
    """
    @brief Read a file with UTF-8 encoding.

    @param file_path Path to the file to read
    @param verbose Enable verbose output

    @return File contents as string

    @raises FileNotFoundError If the file doesn't exist
    @raises IOError If the file cannot be read
    """
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    try:
        if verbose:
            print(f"Reading: {file_path}")
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()
    except IOError as e:
        raise IOError(f"Failed to read {file_path}: {e}")


def write_file(path: Path, data: str, verbose: bool = False) -> None:
    """
    @brief Write data to a file with UTF-8 encoding.

    @param path Path to the file to write
    @param data Content to write
    @param verbose Enable verbose output
    """
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        if verbose:
            print(f"Writing: {path}")
        with open(path, "w", encoding="utf-8") as f:
            f.write(data)
    except IOError as e:
        raise IOError(f"Failed to write {path}: {e}")


def remove_cmake_comments(content: str) -> str:
    """
    @brief Remove CMake comments from content while preserving structure.

    Handles both single-line (#) and multi-line (#[[ ]]) comments.

    @param content CMake file content

    @return Content with comments removed but newlines preserved
    """
    # Remove multi-line comments #[[ ... ]]
    # Use non-greedy matching and DOTALL to handle newlines
    content = re.sub(r"#\[\[.*?\]\]", "", content, flags=re.DOTALL)

    # Remove single-line comments but preserve newlines
    lines = content.split("\n")
    cleaned_lines = []
    for line in lines:
        # Find the # that's not in a string
        # Simple approach: remove everything after # (may need refinement for strings)
        # For more robustness, we'd need a proper CMake parser
        comment_pos = line.find("#")
        if comment_pos != -1:
            # Check if # is inside a quoted string (basic check)
            before = line[:comment_pos]
            # Count quotes before the #
            if before.count('"') % 2 == 0 and before.count("'") % 2 == 0:
                line = line[:comment_pos]
        cleaned_lines.append(line)

    return "\n".join(cleaned_lines)


def extract_include_statements(
    content: str, verbose: bool = False
) -> List[Tuple[str, str, str]]:
    """
    @brief Extract include statements from CMake content.

    Handles multi-line includes and various formatting styles.

    @param content CMake file content
    @param verbose Enable verbose output

    @return List of tuples: (full_match, file_path_expression, original_text_to_replace)
    """
    # Remove comments first to avoid false matches
    content_no_comments = remove_cmake_comments(content)

    # Pattern to match include() statements, potentially across multiple lines
    # This pattern handles:
    # - Optional whitespace before 'include'
    # - The word 'include'
    # - Optional whitespace before '('
    # - Opening '('
    # - Content (potentially multi-line)
    # - Closing ')'
    # Using DOTALL to match newlines, and non-greedy matching
    pattern = r"\binclude\s*\(\s*([^)]+?)\s*\)"

    includes = []
    for match in re.finditer(pattern, content_no_comments, re.IGNORECASE | re.DOTALL):
        file_path_expr = match.group(1).strip()
        # Remove any quotes around the path
        file_path_expr = file_path_expr.strip('"').strip("'")
        # Normalize whitespace (convert multi-line to single line)
        file_path_expr = " ".join(file_path_expr.split())

        full_match = match.group(0)

        includes.append((full_match, file_path_expr, full_match))

        if verbose:
            print(f"Found include: {file_path_expr}")

    return includes


def resolve_cmake_path(path_expr: str, base_dir: Path, verbose: bool = False) -> Path:
    """
    @brief Resolve CMake variable expressions in file paths.

    @param path_expr Path expression potentially containing CMake variables
    @param base_dir Base directory for resolving relative paths
    @param verbose Enable verbose output

    @return Resolved absolute path
    """
    # Replace common CMake variables with empty string since they refer to current dir
    # The path will then be relative to base_dir
    resolved = path_expr.replace("${CMAKE_CURRENT_LIST_DIR}/", "")
    resolved = resolved.replace("${CMAKE_CURRENT_LIST_DIR}", "")
    resolved = resolved.replace("${CMAKE_CURRENT_SOURCE_DIR}/", "")
    resolved = resolved.replace("${CMAKE_CURRENT_SOURCE_DIR}", "")

    # Handle relative paths
    path = Path(resolved)
    if not path.is_absolute():
        path = base_dir / path

    # Normalize the path
    path = path.resolve()

    if verbose:
        print(f"Resolved path: {path_expr} -> {path}")

    return path


def _should_inline_include(path_expr: str) -> bool:
    """Return True if the include path refers to a local file."""
    if (
        "${CMAKE_CURRENT_LIST_DIR}" in path_expr
        or "${CMAKE_CURRENT_SOURCE_DIR}" in path_expr
    ):
        return True

    if "/" in path_expr or "\\" in path_expr or path_expr.endswith(".cmake"):
        return not Path(path_expr).is_absolute()

    return False


def _filter_local_includes(
    includes: List[Tuple[str, str, str]],
) -> List[Tuple[str, str, str]]:
    """Filter and sort local includes for deterministic processing."""
    local_includes = [
        include for include in includes if _should_inline_include(include[1])
    ]
    local_includes.sort(key=lambda inc: inc[1])
    return local_includes


def _inline_local_include(
    full_match: str,
    path_expr: str,
    base_dir: Path,
    processed_files: Set[Path],
    verbose: bool,
) -> Optional[Tuple[str, str]]:
    """
    Read, expand and return the content for a local include.

    Returns None if the include was already processed.
    """
    try:
        resolved_path = resolve_cmake_path(path_expr, base_dir, verbose)
    except Exception as e:
        raise CMakeParseError(f"Failed to resolve path '{path_expr}': {e}") from e

    if resolved_path in processed_files:
        if verbose:
            print(f"Skipping already processed file: {resolved_path}")
        return None

    try:
        included_content = read_file(resolved_path, verbose)
    except Exception as e:
        raise FileNotFoundError(
            f"Cannot read included file '{resolved_path}': {e}"
        ) from e

    nested_processed = processed_files.copy()
    nested_processed.add(resolved_path)

    nested_replacements = build_replacement_dict(
        included_content, resolved_path.parent, nested_processed, verbose
    )

    for nested_pattern, nested_replacement in nested_replacements.items():
        included_content = included_content.replace(nested_pattern, nested_replacement)

    return full_match, included_content


def build_replacement_dict(
    content: str,
    base_dir: Path,
    processed_files: Set[Path] = None,
    verbose: bool = False,
) -> Dict[str, str]:
    """
    @brief Build a dictionary of include statements to their replacement content.

    @param content CMake file content
    @param base_dir Base directory for resolving paths
    @param processed_files Set of already processed files (to detect circular includes)
    @param verbose Enable verbose output

    @return Dictionary mapping include statements to their replacement content

    @raises CMakeParseError If circular includes are detected
    @raises FileNotFoundError If an included file is not found
    """
    if processed_files is None:
        processed_files = set()

    includes = extract_include_statements(content, verbose)
    replace_dict = {}

    for full_match, path_expr, _ in _filter_local_includes(includes):
        inline_result = _inline_local_include(
            full_match, path_expr, base_dir, processed_files, verbose
        )
        if inline_result is None:
            continue
        pattern, included_content = inline_result
        replace_dict[pattern] = included_content

    return replace_dict


def apply_version_placeholder(
    content: str, version_path: Path, verbose: bool = False
) -> str:
    """Embed the semantic version into the main CMake file."""
    major, minor, patch = load_semver(version_path, verbose)
    version_str = format_semver(major, minor, patch)
    if verbose:
        print(f"Inserting version string: {version_str}")
    version_block = render_version_cmake(major, minor, patch).strip()

    pattern = r"#\s*%VERSION%\s*(?:\r?\n)?"
    replacement = version_block + "\n\n"
    replaced_content, count = re.subn(pattern, replacement, content, count=1)

    if count == 0:
        return content.replace("%VERSION%", version_block)
    return replaced_content


def build_release_content(
    src_dir: Path, main_file: str, version_file: Path, verbose: bool = False
) -> str:
    """
    @brief Generate amalgamated release file content.

    @param src_dir Source directory path
    @param main_file Main file name
    @param verbose Enable verbose output

    @return Amalgamated file content
    """
    main_path = src_dir / main_file

    if verbose:
        print(f"Processing main file: {main_path}")

    main_content = read_file(main_path, verbose)
    main_content = apply_version_placeholder(main_content, version_file, verbose)

    # Build replacement dictionary
    replace_dict = build_replacement_dict(main_content, src_dir, verbose=verbose)

    # Apply replacements
    result = main_content
    for pattern, replacement in replace_dict.items():
        if verbose:
            print(f"Replacing include with {len(replacement)} bytes of content")
        # Use a more robust replacement that handles potential regex issues
        result = result.replace(pattern, replacement)

    return result


def check_release_state(
    release_path: Path, new_content: str, verbose: bool = False
) -> int:
    """Validate that the release file matches the generated content."""
    if not release_path.exists():
        print(f"❌ {release_path} is missing (check failed)")
        return 1

    old_content = read_file(release_path, verbose)

    if old_content != new_content:
        print(f"❌ {release_path} is out of date.")
        print(f"   Run: python scripts/generate_release.py")
        return 2

    print(f"✅ {release_path} is up to date.")
    return 0


def write_release_artifact(
    release_path: Path, new_content: str, verbose: bool = False
) -> None:
    """Write the amalgamated content to the release file."""
    write_file(release_path, new_content, verbose)
    print(f"✅ {release_path} generated ({len(new_content)} bytes)")


def run_release_flow(
    src_dir: Path,
    release_path: Path,
    main_file: str,
    version_file: Path,
    check_only: bool,
    verbose: bool = False,
) -> int:
    """Generate or validate the release artifact depending on CLI flags."""
    try:
        new_content = build_release_content(src_dir, main_file, version_file, verbose)

        if check_only:
            return check_release_state(release_path, new_content, verbose)

        write_release_artifact(release_path, new_content, verbose)
        return 0
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        if verbose:
            import traceback

            traceback.print_exc()
        return 3


def main() -> int:
    """Main entry point."""
    args = build_argument_parser().parse_args()

    repo_root = switch_to_repo_root()

    if args.verbose:
        print(f"Repository root: {repo_root}")

    src_dir = Path(args.src_dir)
    release_path = Path(args.output)
    version_path = Path(args.version_file)

    return run_release_flow(
        src_dir, release_path, args.main_file, version_path, args.check, args.verbose
    )


if __name__ == "__main__":
    sys.exit(main())
