#!/usr/bin/env powershell

pushd $PSScriptRoot/..
cmake -G "Ninja" -S . -B ./build
popd

pushd $PSScriptRoot/../build
ninja
popd