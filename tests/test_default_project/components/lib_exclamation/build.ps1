. ./../../env.ps1  # activate environment

# Config
cmake -G "Ninja" -B./build -DCMAKE_BUILD_TYPE="Debug" --log-level=TRACE

# Build
cmake --build ./build

deactivate  # deactivate environment
