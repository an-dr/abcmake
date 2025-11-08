#!/bin/bash
# *************************************************************************
#
# Copyright (c) 2024 Andrei Gramakov. All rights reserved.
#
# abcmake Installation Script for Unix/Linux/macOS
# This script automatically downloads and installs the latest abcmake release.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.sh | bash
#
# Options:
#   --user          Install to ~/.local instead of system-wide
#   --prefix PATH   Install to custom prefix
#   --version TAG   Install specific version (e.g., v6.2.0)
#   --help          Show this help message
#
# *************************************************************************

set -euo pipefail

# Default configuration
REPO_OWNER="an-dr"
REPO_NAME="abcmake"
INSTALL_PREFIX=""
USER_INSTALL=false
VERSION="latest"
TEMP_DIR=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Platform detection
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    DEFAULT_PREFIX="/usr/local"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    DEFAULT_PREFIX="/usr/local"
else
    PLATFORM="unknown"
    DEFAULT_PREFIX="/usr/local"
fi

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show help
show_help() {
    cat << EOF
abcmake Installation Script

USAGE:
    curl -fsSL https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.sh | bash
    wget -qO- https://raw.githubusercontent.com/an-dr/abcmake/main/scripts/install.sh | bash

    bash install.sh [OPTIONS]

OPTIONS:
    --user          Install to ~/.local instead of system-wide (no sudo required)
    --prefix PATH   Install to custom prefix directory
    --version TAG   Install specific version (e.g., v6.2.0, default: latest)
    --help          Show this help message

EXAMPLES:
    # System-wide installation (requires sudo)
    bash install.sh

    # User installation (no sudo required)
    bash install.sh --user

    # Custom prefix
    bash install.sh --prefix /opt/abcmake

    # Specific version
    bash install.sh --version v6.2.0 --user

REQUIREMENTS:
    - curl or wget
    - tar
    - cmake (for using abcmake)

EOF
}

# Cleanup function
cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Download file
download_file() {
    local url="$1"
    local output="$2"
    
    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -qO "$output" "$url"
    else
        log_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
}

# Get latest release tag
get_latest_version() {
    local api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
    local version
    
    if command_exists curl; then
        version=$(curl -fsSL "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    elif command_exists wget; then
        version=$(wget -qO- "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        log_error "Cannot determine latest version without curl or wget"
        exit 1
    fi
    
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest version"
        exit 1
    fi
    
    echo "$version"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user)
                USER_INSTALL=true
                shift
                ;;
            --prefix)
                INSTALL_PREFIX="$2"
                shift 2
                ;;
            --version)
                VERSION="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Determine installation prefix
determine_prefix() {
    if [[ -n "$INSTALL_PREFIX" ]]; then
        # Custom prefix provided
        echo "$INSTALL_PREFIX"
    elif [[ "$USER_INSTALL" == true ]]; then
        # User installation
        echo "$HOME/.local"
    else
        # System installation
        echo "$DEFAULT_PREFIX"
    fi
}

# Check if we need sudo
needs_sudo() {
    local prefix="$1"
    
    if [[ "$USER_INSTALL" == true ]] || [[ "$prefix" == "$HOME"* ]]; then
        return 1  # Don't need sudo
    fi
    
    if [[ ! -w "$prefix" ]] && [[ ! -w "$(dirname "$prefix")" ]]; then
        return 0  # Need sudo
    fi
    
    return 1  # Don't need sudo
}

# Main installation function
install_abcmake() {
    local prefix="$1"
    local version="$2"
    local use_sudo="$3"
    local temp_dir="$4"
    
    log_info "Installing abcmake $version to $prefix"
    
    # Download installation package
    local package_url="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$version/abcmake-$version-install.tar.gz"
    local package_file="$temp_dir/abcmake-install.tar.gz"
    
    log_info "Downloading $package_url"
    download_file "$package_url" "$package_file"
    
    # Create prefix directory
    if [[ "$use_sudo" == true ]]; then
        sudo mkdir -p "$prefix"
    else
        mkdir -p "$prefix"
    fi
    
    # Extract and install
    log_info "Extracting package to $prefix"
    if [[ "$use_sudo" == true ]]; then
        sudo tar -xzf "$package_file" -C "$prefix"
    else
        tar -xzf "$package_file" -C "$prefix"
    fi
    
    # Verify installation
    local cmake_dir="$prefix/share/cmake/abcmake"
    if [[ -f "$cmake_dir/ab.cmake" ]]; then
        log_success "abcmake installed successfully!"
        log_info "Installation directory: $cmake_dir"
    else
        log_error "Installation verification failed"
        return 1
    fi
    
    # Show usage instructions
    show_usage_instructions "$prefix"
}

# Show usage instructions
show_usage_instructions() {
    local prefix="$1"
    
    echo ""
    echo "=== abcmake Installation Complete ==="
    echo ""
    echo "To use abcmake in your CMake projects, add this to your CMakeLists.txt:"
    echo ""
    echo "    find_package(abcmake REQUIRED)"
    echo "    # All abcmake functions are now available"
    echo "    add_main_component(\${PROJECT_NAME})"
    echo ""
    
    if [[ "$prefix" != "/usr/local" ]] && [[ "$prefix" != "/usr" ]]; then
        echo "Since you installed to a custom location, you may need to help CMake find it:"
        echo ""
        echo "Option 1: Set CMAKE_PREFIX_PATH when configuring:"
        echo "    cmake -B build -DCMAKE_PREFIX_PATH=\"$prefix\""
        echo ""
        echo "Option 2: Set it in your CMakeLists.txt before find_package():"
        echo "    list(APPEND CMAKE_PREFIX_PATH \"$prefix\")"
        echo ""
    fi
    
    if [[ "$USER_INSTALL" == true ]]; then
        echo "For user installations, you might want to add this to your shell profile:"
        echo "    export CMAKE_PREFIX_PATH=\"\$HOME/.local:\$CMAKE_PREFIX_PATH\""
        echo ""
    fi
    
    echo "Documentation: https://github.com/$REPO_OWNER/$REPO_NAME"
    echo "Examples: https://github.com/$REPO_OWNER/$REPO_NAME/tree/main/examples"
}

# Main function
main() {
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Parse command line arguments
    parse_args "$@"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    
    # Determine version to install
    if [[ "$VERSION" == "latest" ]]; then
        log_info "Getting latest version..."
        VERSION=$(get_latest_version)
        log_info "Latest version: $VERSION"
    fi
    
    # Determine installation prefix
    PREFIX=$(determine_prefix)
    
    # Check if sudo is needed
    USE_SUDO=false
    if needs_sudo "$PREFIX"; then
        USE_SUDO=true
        log_info "Installation requires sudo privileges"
    fi
    
    # Check prerequisites
    if ! command_exists cmake; then
        log_warning "CMake is not installed. You'll need it to use abcmake."
    fi
    
    if ! command_exists tar; then
        log_error "tar is required but not installed"
        exit 1
    fi
    
    # Install abcmake
    install_abcmake "$PREFIX" "$VERSION" "$USE_SUDO" "$TEMP_DIR"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
