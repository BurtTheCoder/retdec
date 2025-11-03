# Quick Wins Checklist - First 30 Days

This checklist contains high-impact, low-effort improvements you can implement immediately to modernize the RetDec codebase.

**Goal:** Establish foundation for quality and set up automation

---

## Week 1: CI/CD & Cleanup (5 items)

### 1. Remove Travis CI ✓ (5 minutes)
**Impact:** Clean up technical debt, reduce confusion
```bash
git rm .travis.yml
# Update README.md to remove Travis CI badge (line 11)
git commit -m "Remove outdated Travis CI configuration"
```
**Files:**
- `.travis.yml` (delete)
- `README.md` (remove badge)

### 2. Add Code Coverage Tracking 🎯 (4 hours)
**Impact:** Immediate visibility into test quality
```bash
# Add to CMakeLists.txt:
# if(CMAKE_BUILD_TYPE MATCHES Debug AND RETDEC_TESTS)
#   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
# endif()

# Create .github/workflows/coverage.yml
# Sign up for codecov.io (free for open source)
# Add codecov badge to README.md
```
**Files:**
- `CMakeLists.txt` (add coverage flags)
- `.github/workflows/coverage.yml` (new)
- `README.md` (add badge)

**Resources:**
- [Codecov GitHub Action](https://github.com/codecov/codecov-action)
- [gcov/lcov tutorial](https://github.com/linux-test-project/lcov)

### 3. Add clang-format Check 📝 (2 hours)
**Impact:** Consistent code formatting, easier reviews
```bash
# .clang-format already exists!
# Create workflow to check formatting
```
**Files:**
- `.github/workflows/code-quality.yml` (new)

**Workflow content:**
```yaml
name: Code Quality

on: [pull_request]

jobs:
  format-check:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - name: Install clang-format
        run: sudo apt-get install -y clang-format-14
      - name: Check formatting
        run: |
          find src include -name '*.cpp' -o -name '*.h' | \
          xargs clang-format-14 --dry-run --Werror
```

### 4. Add Static Analysis 🔍 (4 hours)
**Impact:** Catch bugs automatically, modernization suggestions
```bash
# Create .clang-tidy configuration
# Add workflow to run clang-tidy on changed files
```
**Files:**
- `.clang-tidy` (new)
- `.github/workflows/static-analysis.yml` (new)

**Sample .clang-tidy:**
```yaml
Checks: >
  bugprone-*,
  modernize-*,
  readability-*,
  performance-*,
  -modernize-use-trailing-return-type,
  -readability-identifier-length

CheckOptions:
  - key: readability-identifier-naming.ClassCase
    value: CamelCase
  - key: readability-identifier-naming.FunctionCase
    value: camelCase
```

### 5. Update CI OS Versions 🖥️ (30 minutes)
**Impact:** Modern platform support
**Files:**
- `.github/workflows/retdec-ci.yml`

**Changes:**
```yaml
# Change:
# macos-11 → macos-13 or macos-latest
# Consider: windows-2019 → windows-2022
```

---

## Week 2: Documentation (3 items)

### 6. Create CONTRIBUTING.md 📚 (4 hours)
**Impact:** Essential for new contributors
**Template structure:**
```markdown
# Contributing to RetDec

## Code Style
- C++17 standard
- Use clang-format (config in .clang-format)
- Follow existing naming conventions

## Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Write tests for new features
4. Ensure all tests pass
5. Update CHANGELOG.md
6. Submit PR

## Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Reference issues (#123)
- Keep first line under 72 characters

## Testing
- Build with -DRETDEC_TESTS=on
- Run: ctest --output-on-failure
- Aim for >80% code coverage

## Code Review
- All PRs require review
- Address review comments
- Keep PRs focused and small
```

### 7. Create PR Template 📋 (30 minutes)
**Impact:** Consistent PR submissions
**File:** `.github/PULL_REQUEST_TEMPLATE.md`

```markdown
## Description
<!-- Describe your changes -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] All tests pass
- [ ] No new compiler warnings
- [ ] Code formatted with clang-format
```

### 8. Create ARCHITECTURE.md (Draft) 🏗️ (8 hours)
**Impact:** Faster onboarding for developers
**Initial structure:**
```markdown
# RetDec Architecture Overview

## High-Level Flow
Binary → bin2llvmir → LLVM IR → llvmir2hll → C/Python

## Core Components
1. bin2llvmir - Binary to LLVM IR conversion
2. llvmir2hll - LLVM IR to high-level language
3. fileformat - Binary format parsing (PE, ELF, Mach-O)
4. capstone2llvmir - Disassembly integration
5. common - Shared data structures

## Module Dependencies
[Add diagram or description]

## Data Flow
[Explain how data flows through the system]

## Key Algorithms
- Type recovery
- Control flow reconstruction
- Function detection
```

---

## Week 3: Security & Dependencies (4 items)

### 9. Add Dependabot 🤖 (15 minutes)
**Impact:** Automated dependency updates
**File:** `.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

### 10. Enable CodeQL Scanning 🔒 (30 minutes)
**Impact:** Security vulnerability detection
**File:** `.github/workflows/codeql.yml`

```yaml
name: "CodeQL"

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Monday

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-22.04
    permissions:
      security-events: write

    strategy:
      matrix:
        language: [ 'cpp' ]

    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
      - uses: github/codeql-action/autobuild@v2
      - uses: github/codeql-action/analyze@v2
```

### 11. Update SECURITY.md 📄 (1 hour)
**Impact:** Clear security policy
**File:** `SECURITY.md`

**Expand to include:**
```markdown
# Security Policy

## Supported Versions
| Version | Supported          |
| ------- | ------------------ |
| 5.0.x   | :white_check_mark: |
| < 5.0   | :x:                |

## Reporting a Vulnerability
[Keep existing content]

## Security Update Policy
- Critical vulnerabilities: Patched within 7 days
- High severity: Patched within 30 days
- Medium severity: Patched in next release

## Known Security Considerations
- RetDec processes untrusted binary input
- Always run in sandboxed environment for untrusted files
- Keep dependencies updated
```

### 12. Update YARA Dependency 🔧 (1 week)
**Impact:** Stability and security improvements
**File:** `cmake/deps.cmake`

```cmake
# Change:
# YARA 4.2.0-rc1 → 4.3.2 or latest stable

set(YARA_URL
    "https://github.com/VirusTotal/yara/archive/refs/tags/v4.3.2.tar.gz"
    CACHE STRING "YARA archive URL"
)

# Update SHA256 hash after downloading
set(YARA_ARCHIVE_SHA256
    "..." # Calculate: sha256sum yara-4.3.2.tar.gz
    CACHE STRING "YARA archive SHA256 checksum"
)
```

**Testing:**
```bash
mkdir build-test && cd build-test
cmake .. -DRETDEC_TESTS=on
make -j$(nproc)
ctest --output-on-failure
```

---

## Week 4: Testing & Polish (3 items)

### 13. Update Capstone Dependency 🔧 (1 week)
**Impact:** Better disassembly stability
**File:** `cmake/deps.cmake`

```cmake
# Change:
# Capstone 5.0-rc2 → 5.1.0 or latest stable

set(CAPSTONE_URL
    "https://github.com/capstone-engine/capstone/archive/refs/tags/5.1.0.tar.gz"
    CACHE STRING "Capstone archive URL"
)

# Update SHA256 hash
set(CAPSTONE_ARCHIVE_SHA256
    "..." # Calculate after download
    CACHE STRING "Capstone archive SHA256 checksum"
)
```

### 14. Add Integration Test Skeleton 🧪 (4 hours)
**Impact:** Framework for end-to-end testing
**Files:**
- `tests/integration/CMakeLists.txt` (new)
- `tests/integration/test_basic_decompilation.cpp` (new)

**Structure:**
```cpp
// tests/integration/test_basic_decompilation.cpp
#include <gtest/gtest.h>
#include "retdec/retdec/retdec.h"

TEST(IntegrationTest, BasicX86Decompilation) {
    // Test complete decompilation flow
    // Binary → LLVM IR → C code
    retdec::Config config;
    auto result = retdec::decompile("test_binary.exe", config);
    ASSERT_TRUE(result.success());
    EXPECT_TRUE(result.containsFunction("main"));
}
```

### 15. Enable Branch Protection 🛡️ (15 minutes)
**Impact:** Enforce quality gates
**Settings:** GitHub Repository Settings → Branches → Add rule

**Rules to enable:**
- ✓ Require pull request reviews (1 reviewer)
- ✓ Require status checks to pass:
  - Code Quality (clang-format)
  - Static Analysis (clang-tidy)
  - Tests (all platforms)
  - CodeQL
  - Coverage (if ready)
- ✓ Require branches to be up to date
- ✓ Include administrators

---

## Progress Tracking

Use this checklist to track your progress:

```
Week 1: CI/CD & Cleanup
[ ] 1. Remove Travis CI
[ ] 2. Add code coverage tracking
[ ] 3. Add clang-format check
[ ] 4. Add static analysis
[ ] 5. Update CI OS versions

Week 2: Documentation
[ ] 6. Create CONTRIBUTING.md
[ ] 7. Create PR template
[ ] 8. Create ARCHITECTURE.md (draft)

Week 3: Security & Dependencies
[ ] 9. Add Dependabot
[ ] 10. Enable CodeQL scanning
[ ] 11. Update SECURITY.md
[ ] 12. Update YARA dependency

Week 4: Testing & Polish
[ ] 13. Update Capstone dependency
[ ] 14. Add integration test skeleton
[ ] 15. Enable branch protection

Completed: 0/15 (0%)
```

---

## Expected Outcomes After 30 Days

### Metrics
- ✓ Code coverage: Visible and tracked
- ✓ Static analysis: Running on every PR
- ✓ Dependencies: 2 critical updates completed (YARA, Capstone)
- ✓ Security: CodeQL and Dependabot active
- ✓ Documentation: CONTRIBUTING.md, PR template, ARCHITECTURE.md draft
- ✓ Quality gates: Branch protection enforced

### Developer Experience
- Clear contribution guidelines
- Automated code quality checks
- Faster PR reviews with templates
- Better onboarding with architecture docs

### Technical Debt
- Outdated Travis CI removed
- Dependencies updated to stable releases
- Security monitoring in place
- Code quality visibility

---

## Need Help?

### Resources
- **MODERNIZATION_ROADMAP.md** - Complete 5-phase plan
- **ANALYSIS_SUMMARY.md** - Executive overview
- **DEPENDENCY_ANALYSIS.md** - Dependency details

### Common Issues

**Issue:** Code coverage not uploading
**Solution:** Check codecov.io token in GitHub Secrets

**Issue:** clang-tidy too slow
**Solution:** Run only on changed files, use caching

**Issue:** Dependency update breaks build
**Solution:** Check CMakeLists.txt for API changes, update tests

**Issue:** YARA/Capstone SHA256 mismatch
**Solution:** Download archive, calculate: `sha256sum file.tar.gz`

---

## Next Steps After 30 Days

Once you complete these quick wins, move to:

1. **Phase 2:** Expand test coverage (60%+ target)
2. **Phase 3:** Rebuild support package (5-year-old signatures)
3. **Phase 4:** CMake modernization (upgrade to 3.21+)
4. **Phase 5:** C++20 evaluation and feature adoption

See **MODERNIZATION_ROADMAP.md** for complete details.

---

*Start with item #1 and work your way down. Each item builds on previous ones for maximum impact!*
