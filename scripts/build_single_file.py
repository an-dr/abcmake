#!/usr/bin/env python3
import argparse
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

ABC_SRC_DIR = "src"
MAIN_FILE = "ab.cmake"
RELEASE_PATH = "dist/single_file/ab.cmake"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build the single-file CMake release.")
    parser.add_argument("--check", action="store_true", help="Only verify the release file.")
    parser.add_argument("--src-dir", type=Path, default=Path(ABC_SRC_DIR))
    parser.add_argument("--main-file", type=str, default=MAIN_FILE)
    parser.add_argument("--output", type=Path, default=Path(RELEASE_PATH))
    return parser.parse_args()


def switch_to_repo_root() -> None:
    os.chdir(Path(__file__).resolve().parent.parent)


def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_file(path: Path, data: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(data, encoding="utf-8")


def remove_cmake_comments(content: str) -> str:
    content = re.sub(r"#\[\[.*?\]\]", "", content, flags=re.DOTALL)
    lines = []
    for line in content.splitlines():
        idx = line.find("#")
        if idx != -1:
            before = line[:idx]
            if before.count('"') % 2 == 0 and before.count("'") % 2 == 0:
                line = line[:idx]
        lines.append(line)
    return "\n".join(lines)


def extract_include_statements(content: str) -> List[Tuple[str, str]]:
    content = remove_cmake_comments(content)
    pattern = r"\binclude\s*\(\s*([^)]+?)\s*\)"
    results = []
    for match in re.finditer(pattern, content, re.IGNORECASE | re.DOTALL):
        expr = match.group(1).strip().strip('"').strip("'")
        expr = " ".join(expr.split())
        results.append((match.group(0), expr))
    return results


def resolve_cmake_path(path_expr: str, base_dir: Path) -> Path:
    resolved = path_expr.replace("${CMAKE_CURRENT_LIST_DIR}/", "").replace(
        "${CMAKE_CURRENT_LIST_DIR}", ""
    )
    resolved = resolved.replace("${CMAKE_CURRENT_SOURCE_DIR}/", "").replace(
        "${CMAKE_CURRENT_SOURCE_DIR}", ""
    )
    path = Path(resolved)
    if not path.is_absolute():
        path = (base_dir / path).resolve()
    return path


def should_inline(path_expr: str) -> bool:
    if "${CMAKE_CURRENT_LIST_DIR}" in path_expr or "${CMAKE_CURRENT_SOURCE_DIR}" in path_expr:
        return True
    if "/" in path_expr or "\\" in path_expr or path_expr.endswith(".cmake"):
        return not Path(path_expr).is_absolute()
    return False


def inline_include(full_match: str, path_expr: str, base_dir: Path, processed: Set[Path]) -> Optional[Tuple[str, str]]:
    path = resolve_cmake_path(path_expr, base_dir)
    if path in processed:
        return None
    processed = processed | {path}
    content = read_file(path)
    nested = build_replacement_dict(content, path.parent, processed)
    for nested_match, nested_text in nested.items():
        content = content.replace(nested_match, nested_text)
    return full_match, content


def build_replacement_dict(
    content: str, base_dir: Path, processed_files: Optional[Set[Path]] = None
) -> Dict[str, str]:
    processed_files = processed_files or set()
    replacements: Dict[str, str] = {}
    for full_match, path_expr in extract_include_statements(content):
        if not should_inline(path_expr):
            continue
        result = inline_include(full_match, path_expr, base_dir, processed_files)
        if result is not None:
            replacements[result[0]] = result[1]
    return replacements

def build_release_content(src_dir: Path, main_file: str) -> str:
    main_path = src_dir / main_file
    content = read_file(main_path)
    replacements = build_replacement_dict(content, src_dir)
    for match, replacement in replacements.items():
        content = content.replace(match, replacement)
    return content


def check_release(output_path: Path, expected: str) -> int:
    if not output_path.exists():
        print(f"❌ {output_path} is missing (check failed)")
        return 1
    if output_path.read_text(encoding="utf-8") != expected:
        print(f"❌ {output_path} is out of date.")
        print("   Run: python scripts/generate_release.py")
        return 2
    print(f"✅ {output_path} is up to date.")
    return 0


def main() -> int:
    args = parse_args()
    switch_to_repo_root()

    try:
        content = build_release_content(args.src_dir, args.main_file)
        if args.check:
            return check_release(args.output, content)
        write_file(args.output, content)
        print(f"✅ {args.output} generated ({len(content)} bytes)")
        return 0
    except Exception as exc:
        print(f"❌ Error: {exc}", file=sys.stderr)
        return 3


if __name__ == "__main__":
    sys.exit(main())
