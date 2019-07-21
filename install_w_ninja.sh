#!/bin/bash

cd $(dirname $0)/..
cmake -G "Ninja" -S . -B ./build
cd ./build
ninja
ninja install
cd ..