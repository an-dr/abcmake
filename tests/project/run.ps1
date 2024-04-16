$ErrorActionPreference = "Stop"

pushd $PSScriptRoot

$git_root = (git rev-parse --show-toplevel)
$env:ABCMAKE_PATH = "$git_root/src"

echo "🚀 Building project"

cmake -B build -DCMAKE_BUILD_TYPE=Release -G "Ninja"
cmake --build build --config Release
cmake --install build --config Release

if ($LASTEXITCODE -ne 0) {
    throw "❌ Build failed"
}
echo "✅ Success"

popd
