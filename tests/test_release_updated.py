#!/usr/bin/env python3
# *************************************************************************
#
# Copyright (c) 2024 Andrei Gramakov. All rights reserved.
#
# site:    https://agramakov.me
# e-mail:  mail@agramakov.me
#
# *************************************************************************
import unittest
import os
import re
import importlib.util
import runpy

ABC_DIR_PATH = "src"


def read_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        data = f.read()
    return data


def set_cwd_to_repo():
    dir_path = os.path.dirname(os.path.realpath(__file__))
    os.chdir(dir_path + "/../")


def get_main_file():
    # read file src\ab.cmake
    return read_file(ABC_DIR_PATH + "/ab.cmake")


def get_lines_starting_with_include(data):
    lines = data.split("\n")
    return [line for line in lines if line.startswith("include")]


def get_list_with_str_containing(data, substr):
    return [line for line in data if substr in line]


def get_replacement_dict(includes: list):
    replace_dict = {}
    for line in includes:
        # include({CMAKE_CURRENT_SOURCE_DIR}/...) -> ...
        search = re.search("include\((.+)\)", line)
        if search:
            found = search.group(1)
        file_path = found.replace("${CMAKE_CURRENT_LIST_DIR}", ABC_DIR_PATH)
        new_data = read_file(file_path)
        replace_dict[line] = new_data
    return replace_dict


def write_file(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(data)


class TestsRelease(unittest.TestCase):

    def test_release_updated(self):
        """Validate that the generated single-file content matches manual inline expansion.

        Dynamically generate the release content using scripts/generate_release.py (importing its build
        function) and compare it with the manual include expansion performed here.
        """
        set_cwd_to_repo()

        # Manual expansion
        main_file = get_main_file()
        includes = get_lines_starting_with_include(main_file)
        includes = get_list_with_str_containing(includes, "CMAKE_CURRENT_LIST_DIR")
        replace_dict = get_replacement_dict(includes)
        manual_expanded = main_file
        for old, new in replace_dict.items():
            manual_expanded = manual_expanded.replace(old, new)

        # Dynamic generation via release script
        gen_path = os.path.join("scripts", "generate_release.py")
        ns = runpy.run_path(gen_path, run_name="__generate_release__")
        if "build_release_content" not in ns:
            self.fail("build_release_content not found in generate_release.py")
        generated = ns["build_release_content"]()

        self.assertEqual(
            manual_expanded,
            generated,
            "Generated release content differs from manual expansion",
        )


if __name__ == "__main__":
    unittest.main()
