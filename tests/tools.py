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
import subprocess
import unittest
import shutil

class TestCMake(unittest.TestCase):
    def setUp(self) -> None:
        self.ROOT_PATH = os.path.dirname(os.path.abspath(__file__))
        os.environ["ABCMAKE_PATH"] = self.ROOT_PATH + "/../src"
        return super().setUp()
    
    def tearDown(self) -> None:
        return super().tearDown()
    
    def build_cmake(self, dir):
        os.chdir(f"{self.ROOT_PATH}/{dir}")
        
        # cleanup
        shutil.rmtree("build", ignore_errors=True)
        shutil.rmtree("install", ignore_errors=True)
        
        p = subprocess.run('cmake -B build -DCMAKE_BUILD_TYPE=Release -G "Ninja"')
        self.assertEqual(p.returncode, 0, p.stdout)
        p = subprocess.run('cmake --build build --config Release')
        self.assertEqual(p.returncode, 0, p.stdout)
        p = subprocess.run('cmake --install build --config Release')
        self.assertEqual(p.returncode, 0, p.stdout)
        os.chdir(self.ROOT_PATH)
