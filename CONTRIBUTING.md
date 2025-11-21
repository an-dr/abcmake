# Contributing to abcmake

Thank you for considering contributing to abcmake! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Documentation](#documentation)

## Code of Conduct

This project adheres to a code of conduct that encourages respectful collaboration. By participating, you are expected to uphold this standard. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear descriptive title**
- **Detailed steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **Environment details** (OS, CMake version, compiler)
- **Minimal reproducible example** if possible
- **Error messages** or logs

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide detailed description** of the proposed feature
- **Explain why this enhancement would be useful**
- **Include code examples** if applicable

### Pull Requests

We actively welcome your pull requests! Here's how to contribute code:

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** with clear, logical commits
3. **Add or update tests** for your changes
4. **Update documentation** to reflect your changes
5. **Ensure the test suite passes**
6. **Submit your pull request**

## Development Setup

### Prerequisites

- CMake >= 3.15
- Python 3.x (for running tests)
- Git

### Setting Up Your Development Environment

1. **Fork and clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/abcmake.git
   cd abcmake
   ```

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install abcmake locally** for testing:
   ```bash
   cmake -B build
   cmake --install build --prefix ~/.local
   ```

## Testing

abcmake uses Python-based integration tests to ensure reliability.

### Running Tests

From the project root:

```bash
cd tests
python -m unittest discover -v
```

### Running Specific Tests

```bash
python -m unittest tests.test_basic -v
```

### Writing Tests

When adding new features:

1. Add test cases in the `tests/` directory
2. Follow the existing test structure
3. Ensure tests are self-contained
4. Test both success and failure scenarios

### Test Coverage

We aim for comprehensive test coverage. Please ensure:

- New features have corresponding tests
- Bug fixes include regression tests
- Edge cases are covered

## Pull Request Process

1. **Update CHANGELOG.md** under the `Unreleased` section with your changes
2. **Update documentation** as needed
3. **Ensure all tests pass** before submitting
4. **Keep PRs focused** - one feature/fix per PR
5. **Write clear commit messages** following these guidelines:
   - Use present tense ("Add feature" not "Added feature")
   - Use imperative mood ("Move cursor to..." not "Moves cursor to...")
   - Limit first line to 72 characters
   - Reference issues and pull requests liberally

### PR Review Process

- Maintainers will review your PR as soon as possible
- Address any requested changes
- Once approved, a maintainer will merge your PR
- Your contribution will be included in the next release

## Coding Standards

### CMake Code Style

- **Indentation**: 4 spaces (no tabs)
- **Function names**: `snake_case`
- **Variable names**: `UPPER_SNAKE_CASE` for cache variables, `snake_case` for local
- **Comments**: Use `#` for single-line comments, keep them clear and concise

### Example

```cmake
# Good
function(my_helper_function target_name)
    set(LOCAL_VAR "value")
    set(CACHE_VAR "value" CACHE STRING "Description")
endfunction()

# Avoid
function(MyHelperFunction targetName)
    set(localVar "value")
endfunction()
```

### Best Practices

- Keep functions focused and single-purpose
- Use meaningful variable names
- Add comments for complex logic
- Avoid global state when possible
- Handle error cases explicitly

## Documentation

### Documentation Requirements

When contributing, please update relevant documentation:

- **README.md** - For user-facing changes
- **docs/api.md** - For API changes
- **docs/examples.md** - For new usage patterns
- **Code comments** - For complex implementations

### Documentation Style

- Write clear, concise documentation
- Include code examples where appropriate
- Use proper Markdown formatting
- Keep language simple and accessible
- Test code examples to ensure they work

## Release Process

Releases are handled by maintainers:

1. Update version numbers
2. Update CHANGELOG.md
3. Create GitHub release
4. Generate single-file distribution (`ab.cmake`)
5. Update documentation as needed

## Questions?

If you have questions about contributing:

- Check existing documentation
- Search closed issues for similar questions
- Open a new issue with your question
- Tag it appropriately

## Recognition

Contributors are recognized in:

- Git history
- Release notes
- GitHub contributors page

Thank you for making abcmake better!
