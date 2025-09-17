import subprocess
import unittest
import os
from tools import TestCMake

class TestBuild(TestCMake):
    
    def test_build_interdep(self):
        self.build_cmake("test_interdep")
    
    def test_default_project(self):
        self.build_cmake("test_default_project")
    
    def test_many_folders(self):
        self.build_cmake("test_many_folders")
    
    def test_many_folders_lib(self):
        self.build_cmake("test_many_folders_lib")
    
    def test_project_custom(self):
        self.build_cmake("test_project_custom")
    
    def test_register(self):
        self.build_cmake("test_register")
    
    def test_compile_commands(self):
        self.build_cmake("test_compile_commands")
        # verify file exists
        self.assertTrue(os.path.exists("test_compile_commands/build/compile_commands.json"),
                        "compile_commands.json does not exist")

    def test_cmake_package(self):
        # Build project that contains a raw CMake package (microlog) inside components
        # and a non-abcmake CMake library (lib_exclamation). Ensures package auto-detection works.
        self.build_cmake("test_cmake_package")


if __name__ == '__main__':
    unittest.main()
