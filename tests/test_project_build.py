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
    
    def test_project_custom(self):
        self.build_cmake("test_project_custom")

    def test_compile_commands(self):
        self.build_cmake("test_compile_commands")
        # verify file exists
        self.assertTrue(os.path.exists("test_compile_commands/build/compile_commands.json"),
                        "compile_commands.json does not exist")


if __name__ == '__main__':
    unittest.main()
