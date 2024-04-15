#!/bin/bash
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

set -e # exit when any command fails
SCRIPT_ROOT=$(dirname $(readlink -f "$0"))
SCRIPT_NAME=$(basename "$0")
function log { echo "- $1 [$(basename "$0")]" ;}

# *************************************************************************


pushd $SCRIPT_ROOT

git_root=$(git rev-parse --show-toplevel)

# Set the ABCMAKE_PATH environment variable
export ABCMAKE_PATH="$git_root/src"

log Run CMake
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
cmake --install build --config Release
log Done

popd
