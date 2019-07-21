cd ..
cmake -G "Ninja" -S . -B ./build
cd ./build
ninja
ninja install
cd ..