# Contributing to RetDec

Thank you for your interest in contributing to RetDec! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Building and Testing](#building-and-testing)
- [Documentation](#documentation)
- [Getting Help](#getting-help)

## Code of Conduct

Please be respectful and considerate of others. We aim to foster an open and welcoming environment for all contributors.

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- A GitHub account
- Git installed and configured
- Development environment set up (see [README.md](README.md) for build instructions)
- Familiarity with C++17
- Understanding of CMake build system

### Setting Up Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/retdec.git
   cd retdec
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/avast/retdec.git
   ```

4. **Build with tests enabled**:
   ```bash
   mkdir build && cd build
   cmake .. -DCMAKE_INSTALL_PREFIX=install -DRETDEC_TESTS=on
   make -j$(nproc)
   ```

5. **Run tests** to ensure everything works:
   ```bash
   ctest --output-on-failure
   ```

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation changes
- `test/` - Test additions or modifications

### 2. Make Your Changes

- Write clean, maintainable code following our style guidelines
- Add tests for new functionality
- Update documentation as needed
- Keep commits focused and atomic

### 3. Test Your Changes

Before submitting:

```bash
# Run unit tests
cd build
ctest --output-on-failure

# Check code formatting
find src include tests -type f \( -name '*.cpp' -o -name '*.h' \) \
  -exec clang-format-14 -i {} \;

# Build in both Debug and Release modes
cmake .. -DCMAKE_BUILD_TYPE=Debug -DRETDEC_TESTS=on
make -j$(nproc)
ctest

cmake .. -DCMAKE_BUILD_TYPE=Release -DRETDEC_TESTS=on
make -j$(nproc)
ctest
```

### 4. Keep Your Branch Updated

Regularly sync with upstream:

```bash
git fetch upstream
git rebase upstream/master
```

## Code Style Guidelines

### C++ Style

RetDec uses **C++17 standard** with the following conventions:

#### Naming Conventions

- **Classes/Structs/Enums**: `CamelCase`
  ```cpp
  class FunctionAnalyzer { ... };
  struct BasicBlock { ... };
  enum class ArchType { ... };
  ```

- **Functions/Methods**: `camelCase`
  ```cpp
  void analyzeFunction();
  bool isValidAddress();
  std::string getName() const;
  ```

- **Variables/Parameters**: `camelCase`
  ```cpp
  int functionCount;
  std::string variableName;
  ```

- **Private Members**: `_prefixed`
  ```cpp
  class MyClass {
  private:
      int _memberVariable;
      std::string _name;
  };
  ```

- **Constants/Macros**: `UPPER_CASE`
  ```cpp
  const int MAX_SIZE = 100;
  #define RETDEC_VERSION "5.0"
  ```

- **Namespaces**: `snake_case` or nested
  ```cpp
  namespace retdec {
  namespace bin2llvmir {
  ```

#### Code Formatting

- **Indentation**: 4 spaces (no tabs)
- **Line length**: 120 characters maximum
- **Braces**: Opening brace on same line (K&R style)
  ```cpp
  if (condition) {
      doSomething();
  } else {
      doSomethingElse();
  }
  ```

- **Use `.clang-format`**: We provide a `.clang-format` configuration file. Format your code before committing:
  ```bash
  clang-format-14 -i path/to/file.cpp
  ```

#### Modern C++ Features

Prefer modern C++ constructs:

- **Smart pointers** over raw pointers:
  ```cpp
  auto ptr = std::make_unique<MyClass>();
  std::shared_ptr<Data> data = getData();
  ```

- **`auto`** for type inference where appropriate:
  ```cpp
  auto result = calculateValue();  // Type is obvious from context
  ```

- **Range-based for loops**:
  ```cpp
  for (const auto& item : container) {
      process(item);
  }
  ```

- **`nullptr`** instead of `NULL`:
  ```cpp
  MyClass* ptr = nullptr;
  ```

- **Enum classes** over plain enums:
  ```cpp
  enum class Status { Success, Failure };
  ```

#### Documentation

Use Doxygen-style comments for all public APIs:

```cpp
/**
 * @brief Analyzes a binary function and extracts control flow.
 *
 * This function performs static analysis on the provided binary
 * function to extract its control flow graph.
 *
 * @param func The function to analyze
 * @param options Analysis options
 * @return Control flow graph, or nullptr on failure
 */
std::unique_ptr<CFG> analyzeFunction(
    const Function& func,
    const AnalysisOptions& options);
```

### CMake Style

- Use lowercase for commands: `add_library()`, `target_link_libraries()`
- Use `target_*` commands instead of global settings
- Indent with 2 spaces

## Testing Requirements

### Writing Tests

All new features and bug fixes **must include tests**:

1. **Unit Tests**: Test individual components in isolation
   - Location: `tests/<module>/`
   - Framework: Google Test
   - Example: `tests/bin2llvmir/providers/tests/abi_tests.cpp`

2. **Test Structure**:
   ```cpp
   #include <gtest/gtest.h>
   #include "retdec/module/your_class.h"

   namespace retdec {
   namespace module {
   namespace tests {

   class YourClassTests : public ::testing::Test {
   protected:
       void SetUp() override {
           // Setup code
       }
   };

   TEST_F(YourClassTests, TestCaseName) {
       // Arrange
       YourClass obj;

       // Act
       auto result = obj.doSomething();

       // Assert
       EXPECT_TRUE(result);
       EXPECT_EQ(expectedValue, result.getValue());
   }

   } // namespace tests
   } // namespace module
   } // namespace retdec
   ```

3. **Test Coverage**: Aim for >80% coverage for new code
4. **Run Tests**: All tests must pass before submitting PR

### Integration Tests

For end-to-end functionality:
- Add integration tests in `tests/integration/`
- Test complete decompilation workflows
- Include sample binaries in `tests/data/`

## Pull Request Process

### Before Submitting

Checklist:
- [ ] Code follows style guidelines
- [ ] Code is formatted with `clang-format`
- [ ] All tests pass (unit and integration)
- [ ] New tests added for new functionality
- [ ] Documentation updated (code comments, README, etc.)
- [ ] CHANGELOG.md updated with your changes
- [ ] No compiler warnings introduced
- [ ] Branch is rebased on latest master

### Submitting PR

1. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request** on GitHub:
   - Use our PR template (auto-filled)
   - Provide clear title and description
   - Reference related issues: "Fixes #123"
   - Add relevant labels

3. **PR Title Format**:
   ```
   [Category] Brief description

   Examples:
   [Feature] Add support for RISC-V architecture
   [Fix] Correct pointer analysis in bin2llvmir
   [Docs] Update installation instructions for macOS
   [Refactor] Modernize string handling with std::string_view
   ```

4. **PR Description**:
   - Explain **what** changed
   - Explain **why** it changed
   - Describe **how** it was tested
   - Include screenshots/examples if relevant

### Code Review Process

1. Automated checks will run (CI, static analysis, tests)
2. Maintainers will review your code
3. Address review comments by pushing new commits
4. Once approved, a maintainer will merge your PR

**Review Expectations**:
- Reviews typically within 1-2 weeks
- Be responsive to feedback
- Be patient with the review process
- Participate in discussion constructively

## Commit Message Guidelines

Write clear, meaningful commit messages:

### Format

```
<type>: <subject>

<body>

<footer>
```

### Type

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `perf`: Performance improvements
- `build`: Build system changes
- `ci`: CI/CD changes
- `chore`: Maintenance tasks

### Subject

- Use imperative mood: "Add feature" not "Added feature"
- Keep under 72 characters
- Don't end with a period
- Be specific and descriptive

### Body (optional)

- Explain **what** and **why**, not **how**
- Wrap at 72 characters
- Separate from subject with blank line

### Footer (optional)

- Reference issues: `Fixes #123`, `Closes #456`
- Note breaking changes: `BREAKING CHANGE: description`

### Examples

```
feat: Add ARM64 calling convention provider

Implements calling convention detection for ARM64 (AArch64)
architecture. Supports both standard and iOS-specific conventions.

Fixes #789
```

```
fix: Correct null pointer dereference in type recovery

The type inference algorithm could dereference a null pointer
when analyzing functions with no return value. Added null check
and test case to prevent regression.

Fixes #1234
```

```
docs: Update build instructions for Ubuntu 24.04

Added new dependency requirements and updated CMake version
recommendation for Ubuntu 24.04 LTS.
```

## Building and Testing

### Quick Build

```bash
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=install -DRETDEC_TESTS=on
make -j$(nproc)
```

### Build Options

```bash
# Debug build with tests
cmake .. -DCMAKE_BUILD_TYPE=Debug -DRETDEC_TESTS=on

# Release build with documentation
cmake .. -DCMAKE_BUILD_TYPE=Release -DRETDEC_DOC=on

# Build specific component only
cmake .. -DRETDEC_ENABLE_BIN2LLVMIR=on
```

### Running Tests

```bash
# All tests
ctest

# Specific test suite
ctest -R bin2llvmir

# Verbose output
ctest --output-on-failure

# Parallel execution
ctest -j$(nproc)
```

### Debugging

```bash
# Build with debug symbols
cmake .. -DCMAKE_BUILD_TYPE=Debug

# Run with GDB
gdb ./bin/retdec-decompiler
```

## Documentation

### Code Documentation

- Document all public APIs with Doxygen comments
- Include `@brief`, `@param`, `@return` tags
- Explain complex algorithms and design decisions
- Keep comments up-to-date with code changes

### User Documentation

When changing user-facing features:
- Update README.md
- Update relevant documentation in `doc/`
- Add examples if applicable

### Generating API Documentation

```bash
cmake .. -DRETDEC_DOC=on
make doc
# Output: build/doc/doxygen/html/index.html
```

## Getting Help

### Resources

- **Documentation**: See [README.md](README.md) and [ARCHITECTURE.md](ARCHITECTURE.md)
- **Issues**: Search existing [GitHub Issues](https://github.com/avast/retdec/issues)
- **Discussions**: Use [GitHub Discussions](https://github.com/avast/retdec/discussions)

### Asking Questions

When asking for help:
1. Check if your question has been asked before
2. Provide context and details
3. Include relevant code snippets or error messages
4. Describe what you've already tried

### Reporting Bugs

Create a detailed issue with:
- **Description**: Clear description of the bug
- **Steps to Reproduce**: Exact steps to trigger the bug
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: OS, compiler, RetDec version
- **Logs**: Relevant error messages or logs

## Recognition

Contributors are recognized in:
- CHANGELOG.md for their changes
- Git history for all contributions
- Special acknowledgment for significant contributions

Thank you for contributing to RetDec! Your efforts help make this project better for everyone.
