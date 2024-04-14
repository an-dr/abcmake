#!/usr/bin/env pwsh
# *************************************************************************
#
# Copyright (c) 2024 Andrei Gramakov. All rights reserved.
#
# This file is licensed under the terms of the MIT license.  
# For a copy, see: https://opensource.org/licenses/MIT
#
# site:    https://agramakov.me
# e-mail:  mail@agramakov.me
#
# *************************************************************************

# repo root
$git_root = (git rev-parse --show-toplevel)

$env:ABCMAKE_PATH = "$git_root/src"
