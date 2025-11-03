# RetDec Integration Tests

This directory contains integration tests that verify end-to-end functionality of the RetDec decompiler.

## Overview

Integration tests differ from unit tests in that they:
- Test complete decompilation workflows (binary → source code)
- Cross multiple components (file parsing → IR → HLL)
- Use real or realistic binary test cases
- Verify actual decompilation output quality

## Running Integration Tests

### Build with Tests Enabled

```bash
mkdir build && cd build
cmake .. -DRETDEC_TESTS=ON -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
```

### Run Integration Tests

```bash
# Run all integration tests
ctest -R integration

# Run specific integration test
./tests/integration/retdec-integration-tests

# Run with verbose output
./tests/integration/retdec-integration-tests --gtest_verbose

# List available tests
./tests/integration/retdec-integration-tests --gtest_list_tests
```

### Run Only Unit Tests (exclude integration)

```bash
ctest -E integration
```

## Test Organization

```
tests/integration/
├── CMakeLists.txt                     # Build configuration
├── README.md                          # This file
├── data/                              # Test binaries and expected outputs
│   ├── simple_x86.exe                 # (future) Simple x86 Windows binary
│   ├── simple_x86_64.elf              # (future) Simple x86-64 Linux binary
│   ├── simple_arm.elf                 # (future) Simple ARM Linux binary
│   └── expected/                      # Expected decompilation outputs
│       ├── simple_x86.c               # Expected output for simple_x86.exe
│       └── ...
├── test_basic_decompilation.cpp       # Basic end-to-end tests
└── test_architecture_support.cpp      # Multi-architecture tests
```

## Current Status

**Status**: 🚧 **Framework Established - Tests Pending**

The integration test framework is set up, but actual test implementations are currently disabled (marked with `DISABLED_`) pending:

1. **Test Binary Creation**: We need to create/collect simple test binaries
2. **Integration with Decompiler API**: Wire up tests to actual decompiler calls
3. **Expected Output Generation**: Create baseline expected outputs

## Adding New Integration Tests

### 1. Create Test File

```cpp
// tests/integration/test_my_feature.cpp
#include <gtest/gtest.h>

namespace retdec::integration::tests {

class MyFeatureTests : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup
    }
};

TEST_F(MyFeatureTests, TestMyFeature) {
    // 1. Prepare test binary
    // 2. Configure decompiler
    // 3. Run decompilation
    // 4. Verify output

    EXPECT_TRUE(/* your assertion */);
}

} // namespace
```

### 2. Add to CMakeLists.txt

```cmake
add_executable(retdec-integration-tests
    test_basic_decompilation.cpp
    test_architecture_support.cpp
    test_my_feature.cpp  # Add your test file
)
```

### 3. Create Test Data

Place test binaries in `data/` directory:

```bash
# Compile a simple test program
gcc -o data/my_test.elf test_program.c

# Or use existing binaries (ensure licensing allows)
cp /path/to/binary data/my_test.exe
```

### 4. Document Test

Add description to this README explaining what the test verifies.

## Test Data Guidelines

### Test Binary Requirements

1. **Licensing**: Only use binaries you have the right to redistribute
2. **Size**: Keep binaries small (<100KB preferred)
3. **Simplicity**: Simple, predictable code for reliable testing
4. **Variety**: Cover different:
   - Architectures (x86, x64, ARM, etc.)
   - File formats (PE, ELF, Mach-O)
   - Compilers (GCC, Clang, MSVC)
   - Optimization levels (-O0, -O2, -O3)

### Creating Test Binaries

Example: Create a simple x86 test binary:

```c
// test_program.c
#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main() {
    int result = add(5, 3);
    printf("Result: %d\n", result);
    return 0;
}
```

Compile:
```bash
# Linux x86-64
gcc -o data/simple_x64.elf test_program.c

# Linux x86 (32-bit)
gcc -m32 -o data/simple_x86.elf test_program.c

# Windows x64 (cross-compile)
x86_64-w64-mingw32-gcc -o data/simple_x64.exe test_program.c

# ARM (cross-compile)
arm-linux-gnueabi-gcc -o data/simple_arm.elf test_program.c
```

## Test Categories

### 1. Basic Decompilation (`test_basic_decompilation.cpp`)

- Binary loading and format detection
- Simple function decompilation
- Control flow reconstruction
- Variable recovery

### 2. Architecture Support (`test_architecture_support.cpp`)

- x86, x86-64, ARM, ARM64, MIPS, PowerPC
- Calling convention detection
- Architecture-specific idioms

### 3. File Format Handling (future)

- PE, ELF, Mach-O, COFF parsing
- Debug information extraction (DWARF, PDB)
- Import/export table handling

### 4. Advanced Features (future)

- C++ class reconstruction (RTTI, vtables)
- Exception handling recovery
- Thread-local storage (TLS)
- Packed binary decompilation

## Debugging Integration Tests

### Enable Debug Logging

```bash
# Set environment variable for verbose logging
export RETDEC_LOG_LEVEL=debug
./tests/integration/retdec-integration-tests
```

### Inspect Intermediate Outputs

Integration tests can save intermediate files for debugging:

```cpp
// In test code
config.setSaveIntermediateFiles(true);
config.setOutputDirectory("/tmp/retdec-test-output");
```

### Use GDB for Debugging

```bash
gdb --args ./tests/integration/retdec-integration-tests --gtest_filter=*MyTest*
```

## Continuous Integration

Integration tests are run as part of CI/CD:

```yaml
# .github/workflows/retdec-ci.yml
- name: Run Integration Tests
  run: |
    cd build
    ctest -R integration --output-on-failure
```

## Performance Benchmarking

Integration tests can also serve as performance benchmarks:

```bash
# Time integration tests
time ctest -R integration

# With detailed profiling
perf record ctest -R integration
perf report
```

## Future Enhancements

- [ ] Add test binaries for all supported architectures
- [ ] Create expected output baselines
- [ ] Implement output comparison (diff expected vs. actual)
- [ ] Add performance regression detection
- [ ] Integrate with fuzzing framework
- [ ] Test packed/obfuscated binaries
- [ ] Add Windows-specific tests (PE, PDB)
- [ ] Test decompilation of real-world open-source projects

## Contributing

When adding integration tests:

1. Follow the test structure in existing files
2. Use descriptive test names
3. Add test binaries to `data/` (with licensing info)
4. Update this README with test descriptions
5. Ensure tests pass in CI before submitting PR

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for general contribution guidelines.

---

**Last Updated**: 2025-11-03
