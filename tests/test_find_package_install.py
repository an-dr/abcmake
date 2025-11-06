import subprocess
import unittest
import os
import shutil
from pathlib import Path

class TestFindPackage(unittest.TestCase):
    """Test that abcmake can be installed and found via find_package()"""

    @classmethod
    def setUpClass(cls):
        """Set up test installation directory"""
        cls.root_dir = Path(__file__).parent.parent
        cls.test_install_dir = cls.root_dir / "test_install"
        cls.build_dir = cls.root_dir / "build"

    def setUp(self):
        """Clean up before each test"""
        # Clean build and install directories
        for dir_path in [self.build_dir, self.test_install_dir]:
            if dir_path.exists():
                shutil.rmtree(dir_path)

    def test_install_and_find_package(self):
        """Test complete workflow: configure, install, and find_package"""

        # Step 1: Configure the project
        print("\n=== Configuring abcmake ===")
        result = subprocess.run(
            ["cmake", "-B", str(self.build_dir), "-G", "Ninja"],
            cwd=self.root_dir,
            capture_output=True,
            text=True
        )
        self.assertEqual(result.returncode, 0,
                        f"CMake configure failed:\n{result.stderr}")
        self.assertIn("abcmake version", result.stderr)

        # Step 2: Install to test location
        print("=== Installing abcmake ===")
        result = subprocess.run(
            ["cmake", "--install", str(self.build_dir),
             "--prefix", str(self.test_install_dir)],
            cwd=self.root_dir,
            capture_output=True,
            text=True
        )
        self.assertEqual(result.returncode, 0,
                        f"CMake install failed:\n{result.stderr}")

        # Verify installation files exist
        install_cmake_dir = self.test_install_dir / "share" / "cmake" / "abcmake"
        self.assertTrue(install_cmake_dir.exists(),
                       f"Install directory not created: {install_cmake_dir}")

        required_files = [
            "ab.cmake",
            "version.cmake",
            "abcmakeConfig.cmake",
            "abcmakeConfigVersion.cmake",
            "abcmake/_abcmake_log.cmake",
            "abcmake/_abcmake_property.cmake",
            "abcmake/_abcmake_add_project.cmake",
            "abcmake/add_component.cmake",
            "abcmake/register_components.cmake",
            "abcmake/target_link_components.cmake",
        ]

        for file_path in required_files:
            full_path = install_cmake_dir / file_path
            self.assertTrue(full_path.exists(),
                          f"Required file not installed: {file_path}")

        # Step 3: Test find_package
        print("=== Testing find_package ===")
        test_script = self.root_dir / "tests" / "test_find_package.cmake"
        result = subprocess.run(
            ["cmake", "-P", str(test_script)],
            cwd=self.root_dir / "tests",
            capture_output=True,
            text=True
        )

        self.assertEqual(result.returncode, 0,
                        f"find_package test failed:\n{result.stderr}")
        self.assertIn("SUCCESS! abcmake package was found!", result.stderr)
        self.assertIn("Found abcmake: 6.2.0", result.stderr)
        self.assertIn("✓ ab.cmake found", result.stderr)

    def test_find_package_with_custom_prefix(self):
        """Test that find_package works with CMAKE_PREFIX_PATH"""

        # Install first
        subprocess.run(
            ["cmake", "-B", str(self.build_dir), "-G", "Ninja"],
            cwd=self.root_dir,
            check=True,
            capture_output=True
        )
        subprocess.run(
            ["cmake", "--install", str(self.build_dir),
             "--prefix", str(self.test_install_dir)],
            cwd=self.root_dir,
            check=True,
            capture_output=True
        )

        # Test with explicit INSTALL_PREFIX
        test_script = self.root_dir / "tests" / "test_find_package.cmake"
        result = subprocess.run(
            ["cmake",
             f"-DINSTALL_PREFIX={self.test_install_dir}",
             "-P", str(test_script)],
            cwd=self.root_dir / "tests",
            capture_output=True,
            text=True
        )

        self.assertEqual(result.returncode, 0,
                        f"find_package with custom prefix failed:\n{result.stderr}")
        self.assertIn("SUCCESS!", result.stderr)


if __name__ == '__main__':
    unittest.main()
