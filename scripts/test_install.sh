#!/bin/bash
# Test script for installation scripts
# This script tests the installation process in different scenarios

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test if installation script exists and is valid
test_install_script_syntax() {
    log_info "Testing install.sh syntax"
    
    if bash -n scripts/install.sh; then
        log_success "install.sh syntax is valid"
    else
        log_error "install.sh has syntax errors"
        return 1
    fi
}

# Test help functionality
test_help_output() {
    log_info "Testing help output"
    
    if bash scripts/install.sh --help | grep -q "abcmake Installation Script"; then
        log_success "Help output contains expected content"
    else
        log_error "Help output is missing or incorrect"
        return 1
    fi
}

# Test that we can determine the latest version
test_version_detection() {
    log_info "Testing version detection"
    
    # This tests the GitHub API call without actually installing
    if command -v curl >/dev/null; then
        local version
        version=$(curl -fsSL "https://api.github.com/repos/an-dr/abcmake/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "")
        
        if [[ -n "$version" && "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            log_success "Version detection works: $version"
        else
            log_error "Version detection failed or returned invalid version: $version"
            return 1
        fi
    else
        log_info "curl not available, skipping version detection test"
    fi
}

# Test PowerShell script syntax (if PowerShell is available)
test_powershell_script() {
    log_info "Testing PowerShell script"
    
    if command -v pwsh >/dev/null; then
        if pwsh -Command "& { Get-Content scripts/install.ps1 | Out-String | Invoke-Expression; Show-Help }" | grep -q "abcmake Installation Script"; then
            log_success "PowerShell script help works"
        else
            log_error "PowerShell script help failed"
            return 1
        fi
    else
        log_info "PowerShell not available, skipping PowerShell tests"
    fi
}

# Test package manager files
test_package_files() {
    log_info "Testing package manager files"
    
    local files=(
        "packages/homebrew/abcmake.rb"
        "packages/chocolatey/abcmake.nuspec"
        "packages/chocolatey/chocolateyinstall.ps1"
        "packages/README.md"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "Package file exists: $file"
        else
            log_error "Missing package file: $file"
            return 1
        fi
    done
}

# Main test function
main() {
    echo "Running installation script tests..."
    echo ""
    
    local tests=(
        "test_install_script_syntax"
        "test_help_output"
        "test_version_detection"
        "test_powershell_script"
        "test_package_files"
    )
    
    local passed=0
    local total=${#tests[@]}
    
    for test in "${tests[@]}"; do
        if $test; then
            ((passed++))
        fi
        echo ""
    done
    
    echo "Test Results: $passed/$total passed"
    
    if [[ $passed -eq $total ]]; then
        log_success "All tests passed!"
        return 0
    else
        log_error "Some tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
