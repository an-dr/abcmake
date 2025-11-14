#!/usr/bin/env python3
# *************************************************************************
#
# Copyright (c) 2024 Andrei Gramakov. All rights reserved.
#
# site:    https://agramakov.me
# e-mail:  mail@agramakov.me
#
# *************************************************************************
import os
import re
import sys

ABC_SRC_DIR = "src"


def read_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        data = f.read()
    return data


def set_cwd_to_repo():
    dir_path = os.path.dirname(os.path.realpath(__file__))
    os.chdir(dir_path + "/../")


def get_main_file():
    "Read main file: src/ab.cmake"
    return read_file(ABC_SRC_DIR + "/ab.cmake")


def get_include_lines(data):
    lines = data.split("\n")
    return [line for line in lines if line.startswith("include")]


def get_list_with_str_containing(data, substr):
    return [line for line in data if substr in line]


def get_replacement_dict(includes: list):
    # Deterministic order
    replace_dict = {}
    for line in sorted(includes):
        search = re.search(r"include\((.+)\)", line)
        if not search:
            continue
        file_path_expr = search.group(1)
        file_path = file_path_expr.replace("${CMAKE_CURRENT_LIST_DIR}", ABC_SRC_DIR)
        new_data = read_file(file_path)
        replace_dict[line] = new_data
    return replace_dict


def write_file(path, data):
    "Create necessary dirs and write utf-8 file"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(data)


def build_release_content():
    "Generates content of the amalgamed release file"
    main_file = get_main_file()
    includes = get_include_lines(main_file)
    includes = get_list_with_str_containing(includes, "CMAKE_CURRENT_LIST_DIR")
    replace_dict = get_replacement_dict(includes)
    for old, new in replace_dict.items():
        main_file = main_file.replace(old, new)
    return main_file


def main():
    set_cwd_to_repo()
    new_content = build_release_content()
    release_path = "release/ab.cmake"
    old_content = None
    if os.path.exists(release_path):
        old_content = read_file(release_path)

    if "--check" in sys.argv:
        if old_content is None:
            print("release/ab.cmake is missing (check failed)")
            sys.exit(1)
        if old_content != new_content:
            print(
                "release/ab.cmake is out of date. Run: python scripts/generate_release.py"
            )
            sys.exit(2)
        print("release/ab.cmake is up to date.")
        return

    write_file(release_path, new_content)
    print("✅ release/ab.cmake generated ({} bytes)".format(len(new_content)))


if __name__ == "__main__":
    main()
