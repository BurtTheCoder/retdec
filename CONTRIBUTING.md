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

RetDec **requires C++17 standard** for all code:

- Do not use C++14 or earlier features when C++17 alternatives exist
- Utilize C++17 features where appropriate (e.g., `std::optional`, `std::variant`, `std::filesystem`, structured bindings)
- All code must compile with C++17-compliant compilers (GCC >= 7, Clang >= 5, MSVC >= 2017)

#### Naming Conventions

Follow these naming conventions **strictly and consistently**:

- **Classes/Structs/Enums**: `CamelCase`
  ```cpp
  class FunctionAnalyzer { ... };
  struct BasicBlock { ... };
  enum class ArchType { ... };
  ```

- **Functions/Methods**: `camelCase` (starting with lowercase)
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

**Always use clang-format** - RetDec provides a `.clang-format` configuration file at the repository root:

- **Automatically format** all C++ files before committing:
  ```bash
  # Format a single file
  clang-format -i path/to/file.cpp

  # Format all modified C++ files
  git diff --name-only --cached | grep -E '\.(cpp|h)$' | xargs clang-format -i
  ```

- **Key formatting rules** (from `.clang-format`):
  - **Indentation**: 4 spaces, tabs for continuation
  - **Column limit**: 120 characters maximum
  - **Pointer alignment**: Left (`int* ptr`, not `int *ptr`)
  - **Braces**: Custom wrapping (AfterControlStatement: Always, AfterFunction: true)
  - **Break before binary operators**: NonAssignment

- **Do not** manually override clang-format settings in code

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

All new features and bug fixes **must include tests**. RetDec uses Google Test framework with **3,317+ test cases**.

#### Test Requirements

1. **All new features require tests**
2. **All bug fixes require regression tests**
3. **Aim for high code coverage** (target >80% for new code)
4. **Tests must pass** with `ctest --output-on-failure`

#### Test Structure

1. **Unit Tests**: Test individual components in isolation
   - Location: `tests/<module>/`
   - Framework: Google Test
   - Example: `tests/bin2llvmir/providers/tests/abi_tests.cpp`

2. **Test Template**:
   ```cpp
   #include <gtest/gtest.h>
   #include "retdec/module/your_class.h"

   namespace retdec {
   namespace module {
   namespace tests {

   class YourClassTests : public ::testing::Test {
   protected:
       void SetUp() override {
           // Setup code - runs before each test
       }

       void TearDown() override {
           // Cleanup code - runs after each test
       }
   };

   TEST_F(YourClassTests, DescriptiveTestName) {
       // Arrange - set up test data
       YourClass obj;
       int expectedValue = 42;

       // Act - perform the action being tested
       auto result = obj.doSomething();

       // Assert - verify the results
       EXPECT_TRUE(result.isValid());
       EXPECT_EQ(expectedValue, result.getValue());
       ASSERT_NE(nullptr, result.getPointer());
   }

   TEST_F(YourClassTests, HandlesErrorCase) {
       YourClass obj;

       // Test error handling
       EXPECT_THROW(obj.invalidOperation(), std::runtime_error);
   }

   } // namespace tests
   } // namespace module
   } // namespace retdec
   ```

3. **Test Coverage Goals**:
   - **New features**: Aim for >80% code coverage
   - **Bug fixes**: Include test that would fail without the fix
   - **Edge cases**: Test boundary conditions, null inputs, error paths

### Integration Tests

For end-to-end functionality:
- Add integration tests in `tests/integration/`
- Test complete decompilation workflows
- Include sample binaries in `tests/data/`

## Pull Request Process

### Before Submitting

**Checklist - all items required:**

- [ ] Code follows style guidelines (C++17, naming conventions)
- [ ] Code is formatted with `clang-format` using `.clang-format` config
- [ ] All tests pass: `ctest --output-on-failure`
- [ ] New tests added for new functionality
- [ ] **CHANGELOG.md updated** with your changes under `# dev` section
- [ ] Documentation updated (code comments, README, etc.)
- [ ] No compiler warnings introduced
- [ ] Branch is rebased on latest master

### Updating CHANGELOG.md

**Every PR must update CHANGELOG.md:**

1. Add entry under `# dev` section at the top of the file
2. Use the appropriate prefix:
   - `* New Feature:` for new functionality
   - `* Enhancement:` for improvements to existing features
   - `* Fix:` for bug fixes
3. Format: `* Category: Brief description (#PR_number, #issue_number).`
4. Reference issues with `#123` syntax

**Example:**
```markdown
# dev

* Enhancement: Add support for ARM64 relocations (#456, #123).
* Fix: Correct null pointer dereference in type recovery (#789).
```

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

All PRs require code review before merging:

1. **Automated checks** will run (CI, tests, static analysis)
2. **Maintainers review** your code (may take 1-2 weeks)
3. **Address feedback** by pushing new commits to your branch
4. **Request re-review** after making changes
5. **Maintainer merges** once approved

**Keep PRs Focused and Small:**
- **One feature/fix per PR** - easier to review and merge
- **Split large changes** into multiple smaller PRs
- **Avoid scope creep** - stay focused on the stated goal
- **Small PRs get reviewed faster**

**Review Expectations:**
- All PRs require at least one review from a maintainer
- Be responsive to review comments
- Address all feedback before approval
- Keep discussions professional and constructive
- Be patient - RetDec is in **limited maintenance mode**

**Project Status Note:**
RetDec is currently in **limited maintenance mode**:
- PRs are welcomed and reviewed with priority
- Issues may be addressed with delays
- High-quality PRs with tests are prioritized

## Commit Message Guidelines

Write clear, meaningful commit messages that help reviewers understand your changes.

### Rules

1. **Use present tense**: "Add feature" not "Added feature"
2. **Use imperative mood**: "Fix bug" not "Fixes bug" or "Fixed bug"
3. **Keep first line under 72 characters**: Ideally 50, maximum 72
4. **Reference issues**: Use `#123` to link related issues
5. **Don't end subject with period**: Keep it clean
6. **Capitalize first letter**: Start with uppercase

### Format

```
Brief summary of change (50-72 characters)

Optional detailed explanation of what changed and why.
Wrap lines at 72 characters. Leave a blank line between
the subject and body.

Reference related issues using #123 syntax.
```

### Examples

**Good commit messages:**

```
Add support for ARM64 calling conventions

Implement detection and analysis of ARM64 AArch64 calling
conventions including standard AAPCS64 and iOS-specific
variants. This enables proper decompilation of ARM64 binaries.

Fixes #789
```

```
Fix null pointer dereference in type recovery

The type inference algorithm could crash when analyzing
functions with no return value. Add null check before
pointer access and corresponding test case.

Fixes #1234
```

```
Update CHANGELOG.md with v5.0 release notes

Add comprehensive list of changes, enhancements, and fixes
for the 5.0 release.
```

**Bad commit messages:**

```
fixed stuff
```

```
Added changes to parser and updated docs and fixed bug
```

```
WIP
```

### Referencing Issues

- Use `#123` to reference issue number 123
- Use `Fixes #123` to automatically close issue when merged
- Use `Relates to #123` for related but not closing issues

**Examples:**
- `Fixes #456` - Closes issue 456
- `Addresses #789` - References issue 789
- `See #123, #456` - Multiple issue references

## Building and Testing

### Quick Build

```bash
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=install -DRETDEC_TESTS=on
make -j$(nproc)
```

### Build with Tests (Required for Contributors)

All contributors **must** build with tests enabled:

```bash
mkdir build && cd build
cmake .. -DRETDEC_TESTS=on
make -j$(nproc)
```

### Running Tests

**Run tests before submitting any PR:**

```bash
# All tests with failure output
ctest --output-on-failure

# Run tests in parallel (faster)
ctest -j$(nproc) --output-on-failure

# Specific test suite
ctest -R bin2llvmir --output-on-failure

# Verbose output for debugging
ctest -V
```

**Important:** All tests must pass before your PR will be accepted.

### Build Options

```bash
# Debug build with tests (recommended for development)
cmake .. -DCMAKE_BUILD_TYPE=Debug -DRETDEC_TESTS=on

# Release build with documentation
cmake .. -DCMAKE_BUILD_TYPE=Release -DRETDEC_DOC=on

# Build specific component only
cmake .. -DRETDEC_ENABLE_BIN2LLVMIR=on
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
