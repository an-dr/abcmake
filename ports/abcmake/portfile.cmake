# This overlay port installs abcmake from the local source tree.
# For the official vcpkg registry, see the release artifacts which
# contain a portfile with the correct REF and SHA512.

set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../..")

# abcmake is a pure CMake module - no compilation needed
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Remove empty directories that vcpkg doesn't expect
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
