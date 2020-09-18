#!/usr/bin/env bash
SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $SCRIPT_ROOT/..
cmake -G "Ninja" -S . -B ./build
popd

pushd $SCRIPT_ROOT/../build
ninja
popd