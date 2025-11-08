# abcmake Homebrew Formula
# For future submission to homebrew-core or a custom tap

class Abcmake < Formula
  desc "CMake module for C/C++ projects with predefined standard structure"
  homepage "https://github.com/an-dr/abcmake"
  url "https://github.com/an-dr/abcmake/archive/v6.2.0.tar.gz"
  sha256 "SHA256_PLACEHOLDER"  # Update with actual SHA256
  license "MIT"

  depends_on "cmake" => :build
  uses_from_macos "cmake"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--install", "build"
  end

  test do
    # Create a minimal test project
    (testpath/"CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 3.15)
      project(TestProject)
      find_package(abcmake REQUIRED)
      add_main_component(${PROJECT_NAME})
    EOS

    (testpath/"src"/"main.cpp").write <<~EOS
      #include <iostream>
      int main() {
          std::cout << "Hello, abcmake!" << std::endl;
          return 0;
      }
    EOS

    # Test that CMake can find and configure with abcmake
    system "cmake", "-B", "build", testpath
    system "cmake", "--build", "build"
  end
end