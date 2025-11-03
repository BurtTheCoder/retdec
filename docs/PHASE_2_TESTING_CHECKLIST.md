# Phase 2: Testing Improvements - Action Checklist

**Status:** Ready to begin
**Start Date:** TBD
**Duration:** 12 weeks (6 sprints)
**Goal:** Eliminate critical test coverage gaps and modernize test infrastructure

---

## Pre-Phase 2: Preparation (Week 0)

### Planning & Team Alignment

- [ ] Review TEST_SUITE_ANALYSIS.md with development team
- [ ] Confirm sprint timeline and resource allocation
- [ ] Assign module ownership for under-tested components:
  - [ ] config/ module owner: _______________
  - [ ] ctypesparser/ module owner: _______________
  - [ ] llvmir-emul/ module owner: _______________
  - [ ] loader/ module owner: _______________
  - [ ] unpacker/ module owner: _______________
  - [ ] serdes/ module owner: _______________
- [ ] Set up project tracking (GitHub Projects, JIRA, etc.)
- [ ] Schedule weekly testing sync meetings

### Environment Setup

- [ ] Ensure all developers can build and run tests locally
- [ ] Verify CI/CD pipeline runs existing tests
- [ ] Document current test execution procedure
- [ ] Baseline test execution time (for performance tracking)

---

## Sprint 1: config/ Module Test Expansion (Weeks 1-2)

**Goal:** Expand config/ from 1 to 15+ test files

### Week 1: Analysis & Core Tests

- [ ] **Day 1-2:** Analyze config module source code
  - [ ] List all configuration parameters
  - [ ] Identify validation logic
  - [ ] Map configuration flow through system
  - [ ] Document edge cases

- [ ] **Day 3-5:** Create core test files
  - [ ] `config_parameters_tests.cpp` - All config parameters
  - [ ] `config_validation_tests.cpp` - Validation logic
  - [ ] `config_json_parsing_tests.cpp` - JSON parsing edge cases
  - [ ] `config_file_handling_tests.cpp` - File I/O operations
  - [ ] `config_error_handling_tests.cpp` - Error scenarios

### Week 2: Advanced Tests & Integration

- [ ] **Day 1-3:** Architecture-specific configuration
  - [ ] `config_x86_tests.cpp` - x86/x64 configs
  - [ ] `config_arm_tests.cpp` - ARM configs
  - [ ] `config_mips_tests.cpp` - MIPS configs
  - [ ] `config_powerpc_tests.cpp` - PowerPC configs

- [ ] **Day 4-5:** Advanced scenarios
  - [ ] `config_migration_tests.cpp` - Config version upgrades
  - [ ] `config_merge_tests.cpp` - Config merging/inheritance
  - [ ] `config_defaults_tests.cpp` - Default value handling
  - [ ] `config_serialization_tests.cpp` - Save/load roundtrip
  - [ ] `config_edge_cases_tests.cpp` - Edge cases

- [ ] **End of Sprint 1:**
  - [ ] All 14+ new config tests passing
  - [ ] CI/CD updated to run new tests
  - [ ] Code review completed
  - [ ] Documentation updated

**Deliverable:** config/ module has 15+ test files, comprehensive coverage

---

## Sprint 2: ctypesparser/ & llvmir-emul/ (Weeks 3-4)

**Goal:** Expand ctypesparser/ from 1 to 10+ files, llvmir-emul/ from 1 to 8+ files

### Week 3: ctypesparser/ Module

- [ ] **Day 1-2:** Complex type parsing
  - [ ] `ctypesparser_pointers_tests.cpp` - Pointer types
  - [ ] `ctypesparser_arrays_tests.cpp` - Array types
  - [ ] `ctypesparser_functions_tests.cpp` - Function types

- [ ] **Day 3-5:** Advanced parsing
  - [ ] `ctypesparser_structs_tests.cpp` - Struct/union parsing
  - [ ] `ctypesparser_qualifiers_tests.cpp` - const/volatile/restrict
  - [ ] `ctypesparser_edge_cases_tests.cpp` - Edge cases
  - [ ] `ctypesparser_error_recovery_tests.cpp` - Error handling
  - [ ] `ctypesparser_platform_tests.cpp` - Platform-specific types
  - [ ] `ctypesparser_cpp_tests.cpp` - C++ type support

### Week 4: llvmir-emul/ Module

- [ ] **Day 1-2:** Architecture-specific emulation
  - [ ] `llvmir_emul_x86_tests.cpp` - x86 instruction emulation
  - [ ] `llvmir_emul_arm_tests.cpp` - ARM instruction emulation

- [ ] **Day 3-5:** Emulation scenarios
  - [ ] `llvmir_emul_memory_tests.cpp` - Memory access emulation
  - [ ] `llvmir_emul_control_flow_tests.cpp` - Control flow
  - [ ] `llvmir_emul_edge_cases_tests.cpp` - Edge cases
  - [ ] `llvmir_emul_error_handling_tests.cpp` - Error scenarios
  - [ ] `llvmir_emul_performance_tests.cpp` - Performance regression

- [ ] **End of Sprint 2:**
  - [ ] ctypesparser/: 10+ test files
  - [ ] llvmir-emul/: 8+ test files
  - [ ] All tests passing
  - [ ] CI/CD updated

**Deliverable:** Critical coverage gaps eliminated (all modules have 5+ test files)

---

## Sprint 3: loader/ Module Expansion (Weeks 5-6)

**Goal:** Expand loader/ from 4 to 15+ test files

### Week 5: Format-Specific Loaders

- [ ] **Day 1-2:** PE loader tests
  - [ ] `loader_pe_basic_tests.cpp` - Basic PE loading
  - [ ] `loader_pe_sections_tests.cpp` - PE sections
  - [ ] `loader_pe_imports_tests.cpp` - Import table

- [ ] **Day 3-5:** ELF loader tests
  - [ ] `loader_elf_basic_tests.cpp` - Basic ELF loading
  - [ ] `loader_elf_sections_tests.cpp` - ELF sections
  - [ ] `loader_elf_symbols_tests.cpp` - Symbol table
  - [ ] `loader_elf_relocations_tests.cpp` - Relocations

### Week 6: Additional Loaders & Advanced Tests

- [ ] **Day 1-2:** Mach-O loader
  - [ ] `loader_macho_basic_tests.cpp` - Basic Mach-O loading
  - [ ] `loader_macho_segments_tests.cpp` - Mach-O segments

- [ ] **Day 3-5:** Error handling & edge cases
  - [ ] `loader_corrupted_tests.cpp` - Corrupted binary handling
  - [ ] `loader_edge_cases_tests.cpp` - Edge cases
  - [ ] `loader_exports_tests.cpp` - Export table handling

- [ ] **End of Sprint 3:**
  - [ ] loader/: 15+ test files
  - [ ] All major file formats covered
  - [ ] CI/CD updated

**Deliverable:** Comprehensive loader test coverage for PE/ELF/Mach-O

---

## Sprint 4: unpacker/ & serdes/ (Weeks 7-8)

**Goal:** Expand unpacker/ from 2 to 10+ files, serdes/ from 3 to 12+ files

### Week 7: unpacker/ Module

- [ ] **Day 1-2:** UPX unpacker
  - [ ] `unpacker_upx_basic_tests.cpp` - Basic UPX unpacking
  - [ ] `unpacker_upx_variants_tests.cpp` - UPX variants

- [ ] **Day 3-5:** Other packers & error handling
  - [ ] `unpacker_aspack_tests.cpp` - ASPack
  - [ ] `unpacker_pecompact_tests.cpp` - PECompact
  - [ ] `unpacker_mpress_tests.cpp` - MPRESS
  - [ ] `unpacker_error_tests.cpp` - Error scenarios
  - [ ] `unpacker_nested_tests.cpp` - Nested packers
  - [ ] `unpacker_edge_cases_tests.cpp` - Edge cases

### Week 8: serdes/ Module

- [ ] **Day 1-2:** Serialization formats
  - [ ] `serdes_json_tests.cpp` - JSON serialization
  - [ ] `serdes_binary_tests.cpp` - Binary serialization
  - [ ] `serdes_roundtrip_tests.cpp` - Save/load roundtrip

- [ ] **Day 3-5:** Advanced serialization
  - [ ] `serdes_version_tests.cpp` - Version compatibility
  - [ ] `serdes_edge_cases_tests.cpp` - Edge cases
  - [ ] `serdes_performance_tests.cpp` - Performance
  - [ ] `serdes_large_structures_tests.cpp` - Large structures
  - [ ] `serdes_circular_refs_tests.cpp` - Circular references
  - [ ] `serdes_schema_tests.cpp` - Schema evolution

- [ ] **End of Sprint 4:**
  - [ ] unpacker/: 10+ test files
  - [ ] serdes/: 12+ test files
  - [ ] All high-priority modules expanded

**Deliverable:** All Tier 2 high-priority modules have comprehensive coverage

---

## Sprint 5: Infrastructure Upgrades (Weeks 9-10)

**Goal:** Modernize test infrastructure and tooling

### Week 9: Google Test Upgrade & Code Coverage

- [ ] **Day 1-2:** Google Test upgrade
  - [ ] Update `cmake/deps.cmake` with Google Test 1.14.0 or 1.15.x URL
  - [ ] Update SHA256 hash
  - [ ] Build and test compatibility
  - [ ] Fix any breaking changes
  - [ ] Update CI/CD to use new version

- [ ] **Day 3-5:** Code coverage implementation
  - [ ] Add CMake coverage configuration
  - [ ] Integrate lcov/gcov
  - [ ] Set up Codecov or Coveralls
  - [ ] Generate baseline coverage report
  - [ ] Add coverage to CI/CD pipeline

### Week 10: Test Data Infrastructure & Integration Tests

- [ ] **Day 1-2:** Test data infrastructure
  - [ ] Create `/tests/data/binaries/` directory structure
  - [ ] Organize by format: `/pe/`, `/elf/`, `/macho/`
  - [ ] Create `/tests/data/expected/` for golden files
  - [ ] Document test data requirements
  - [ ] Add test binary download mechanism (if large)

- [ ] **Day 3-5:** Integration tests expansion
  - [ ] `test_x86_decompilation.cpp` - x86 end-to-end
  - [ ] `test_x64_decompilation.cpp` - x64 end-to-end
  - [ ] `test_arm_decompilation.cpp` - ARM end-to-end
  - [ ] `test_mips_decompilation.cpp` - MIPS end-to-end
  - [ ] `test_pe_decompilation.cpp` - PE format
  - [ ] `test_elf_decompilation.cpp` - ELF format
  - [ ] `test_macho_decompilation.cpp` - Mach-O format
  - [ ] `test_packed_binary.cpp` - Packed binary
  - [ ] `test_stripped_binary.cpp` - Stripped binary
  - [ ] `test_obfuscated_code.cpp` - Obfuscated code

- [ ] **End of Sprint 5:**
  - [ ] Google Test upgraded
  - [ ] Code coverage enabled
  - [ ] Test data infrastructure in place
  - [ ] 10+ new integration tests

**Deliverable:** Modern test infrastructure and expanded integration testing

---

## Sprint 6: Quality & Documentation (Weeks 11-12)

**Goal:** Add advanced testing features and comprehensive documentation

### Week 11: Advanced Test Types

- [ ] **Day 1-2:** Parameterized tests
  - [ ] Identify modules benefiting from parameterization
  - [ ] Implement architecture-parameterized tests
  - [ ] Implement format-parameterized tests
  - [ ] Document parameterized test patterns

- [ ] **Day 3-5:** Performance benchmarks
  - [ ] Integrate Google Benchmark (optional)
  - [ ] Add benchmarks for critical paths:
    - [ ] Binary loading performance
    - [ ] Decompilation speed
    - [ ] Optimization pass performance
  - [ ] Establish baseline metrics
  - [ ] Add benchmark to CI/CD

### Week 12: Documentation & Finalization

- [ ] **Day 1-2:** Testing documentation
  - [ ] Create `docs/TESTING_GUIDE.md`
    - [ ] How to write tests
    - [ ] Test organization principles
    - [ ] Running tests locally
    - [ ] CI/CD test execution
  - [ ] Document test data requirements
  - [ ] Create testing best practices guide

- [ ] **Day 3-5:** Additional integration tests & wrap-up
  - [ ] `test_performance_regression.cpp` - Performance baseline
  - [ ] `test_memory_leak_detection.cpp` - Memory safety
  - [ ] `test_error_recovery.cpp` - Error handling
  - [ ] `test_concurrent_decompilation.cpp` - Concurrency
  - [ ] `test_large_binary.cpp` - Large binary handling
  - [ ] `test_complex_binary.cpp` - Complex binary
  - [ ] `test_cross_platform.cpp` - Cross-platform
  - [ ] `test_api_stability.cpp` - API stability

- [ ] **Final Review:**
  - [ ] Generate final code coverage report
  - [ ] Review all test metrics vs. targets
  - [ ] Document lessons learned
  - [ ] Plan for Phase 3 (if needed)

- [ ] **End of Sprint 6:**
  - [ ] All documentation complete
  - [ ] 8+ additional integration tests
  - [ ] Performance benchmarks in place
  - [ ] Code coverage ≥70%

**Deliverable:** Complete testing documentation and advanced test infrastructure

---

## Phase 2 Completion Checklist

### Quantitative Targets

- [ ] Total test files: ≥450 (from 257)
- [ ] Total test cases: ≥7,000 (from 5,205)
- [ ] Modules with <5 tests: 0 (from 6)
- [ ] Integration tests: ≥20 (from 2)
- [ ] Code coverage: ≥70% (from unknown)
- [ ] Google Test version: 2024 (from 2019)

### Module-Specific Targets

- [ ] config/: ≥15 test files (from 1)
- [ ] ctypesparser/: ≥10 test files (from 1)
- [ ] llvmir-emul/: ≥8 test files (from 1)
- [ ] loader/: ≥15 test files (from 4)
- [ ] unpacker/: ≥10 test files (from 2)
- [ ] serdes/: ≥12 test files (from 3)

### Infrastructure Targets

- [ ] Google Test upgraded to v1.14/v1.15
- [ ] Code coverage tooling integrated
- [ ] Test data repository established
- [ ] Golden file testing implemented
- [ ] Performance benchmarks in place
- [ ] CI/CD runs all tests automatically

### Documentation Targets

- [ ] TESTING_GUIDE.md created
- [ ] Test coverage reports generated
- [ ] Testing best practices documented
- [ ] Contributor guidelines updated

---

## Success Criteria

Phase 2 is considered successful when:

1. **All critical coverage gaps eliminated**
   - Every module has ≥5 test files
   - No single-file test modules remain

2. **Modern test infrastructure in place**
   - Google Test 2024
   - Code coverage ≥70%
   - Automated CI/CD testing

3. **Comprehensive documentation**
   - Testing guide available
   - Contributors can easily add tests
   - Test data requirements documented

4. **Enhanced confidence in codebase**
   - Refactoring supported by tests
   - Bug detection improved
   - Regression prevention

---

## Risk Management

### Potential Blockers

| Risk | Mitigation |
|------|------------|
| **Resource constraints** | Prioritize Tier 1 critical modules; extend timeline if needed |
| **Breaking changes in Google Test upgrade** | Allocate extra time in Sprint 5; consider LTS version (1.14) |
| **Large test binaries** | Use external storage (Git LFS, cloud storage) with download scripts |
| **CI/CD performance degradation** | Parallelize tests; use test caching; selective test runs for PRs |
| **Team availability** | Cross-train on modules; document progress for handoffs |

### Contingency Plans

- **If timeline slips:** Prioritize Tier 1 (config, ctypesparser, llvmir-emul) over Tier 2
- **If coverage targets not met:** Extend Sprint 6 by 1-2 weeks
- **If Google Test upgrade fails:** Defer to post-Phase 2; continue with 2019 version
- **If test data too large:** Use minimal test set; expand later

---

## Metrics Tracking

### Weekly Metrics to Track

- Number of test files added
- Number of test cases added
- Code coverage percentage (if available)
- CI/CD test execution time
- Test failure rate

### Sprint Review Template

```markdown
## Sprint X Review

**Completed:**
- [ ] Module tests expanded: _____ files added
- [ ] Total new test cases: _____
- [ ] Code coverage: _____%
- [ ] Blockers resolved: _____

**In Progress:**
- [ ] ...

**Blocked:**
- [ ] ...

**Next Sprint:**
- [ ] ...
```

---

## Getting Started

### Immediate Next Steps (This Week)

1. **Review this checklist** with the team
2. **Assign module owners** (listed in Pre-Phase 2 section)
3. **Set up project tracking** (GitHub Projects, JIRA, etc.)
4. **Schedule Sprint 1 kickoff** meeting
5. **Clone this checklist** to your project management tool
6. **Begin Sprint 1:** config/ module analysis and test planning

### Resources Needed

- Developer time: 1-2 engineers per sprint (can rotate)
- CI/CD credits: Increased test execution time
- Test data storage: ~500MB for test binaries (estimate)
- Documentation time: Technical writer (optional, Sprint 6)

---

## Appendix: Module Prioritization Rationale

### Why config/ is Tier 1 Critical

- **Impact:** Configuration errors affect entire decompilation pipeline
- **Risk:** Incorrect architecture config leads to wrong disassembly
- **Current state:** 1 test file, minimal coverage
- **Justification:** Foundation module; bugs cascade everywhere

### Why ctypesparser/ is Tier 1 Critical

- **Impact:** Type parsing errors lead to incorrect type inference
- **Risk:** Decompiled code has wrong types, confusing output
- **Current state:** 1 test file, basic coverage only
- **Justification:** Type accuracy is core to decompilation quality

### Why llvmir-emul/ is Tier 1 Critical

- **Impact:** Emulation errors affect optimization and analysis
- **Risk:** Incorrect symbolic execution, missed optimizations
- **Current state:** 1 test file, limited architecture coverage
- **Justification:** Critical for advanced analysis features

### Why loader/ is Tier 2 High Priority

- **Impact:** Loading errors prevent analysis entirely
- **Risk:** Can't handle certain PE/ELF/Mach-O variants
- **Current state:** 4 test files, basic scenarios only
- **Justification:** Entry point to analysis; must be robust

---

**Ready to begin?** Start with Sprint 1 and check off items as you go!

For questions or updates, refer to:
- Full analysis: `/mnt/dev/retdec/docs/TEST_SUITE_ANALYSIS.md`
- This checklist: `/mnt/dev/retdec/docs/PHASE_2_TESTING_CHECKLIST.md`
