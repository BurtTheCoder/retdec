# RetDec Architecture Overview

This document provides a high-level overview of RetDec's architecture, component organization, and data flow.

## Table of Contents

- [Introduction](#introduction)
- [High-Level Architecture](#high-level-architecture)
- [Core Components](#core-components)
- [Data Flow](#data-flow)
- [Module Dependencies](#module-dependencies)
- [Key Algorithms](#key-algorithms)
- [Extension Points](#extension-points)
- [Development Guide](#development-guide)

---

## Introduction

RetDec is a **retargetable machine-code decompiler** that converts binary executables back into high-level source code (C or Python-like output). It is built on top of LLVM and uses a multi-stage pipeline architecture.

### Design Philosophy

- **Retargetable**: Not limited to specific architectures or file formats
- **LLVM-based**: Leverages LLVM's intermediate representation and optimization passes
- **Modular**: Clean separation between binary parsing, IR generation, and code emission
- **Extensible**: Plugin architecture for custom analyses and output formats

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           RetDec Pipeline                            │
└─────────────────────────────────────────────────────────────────────┘

    Input Binary
         │
         ▼
    ┌────────────────┐
    │  File Format   │  ← Detect format (PE, ELF, Mach-O, etc.)
    │    Detection   │    Parse headers and sections
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │  Disassembly   │  ← Capstone: Disassemble machine code
    │  (Capstone)    │    Identify functions and basic blocks
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │  bin2llvmir    │  ← Convert to LLVM IR
    │  Translation   │    Lift machine code to LLVM instructions
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ LLVM IR        │  ← LLVM optimization passes
    │ Optimization   │    Dead code elimination, constant folding, etc.
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │  llvmir2hll    │  ← Convert LLVM IR to high-level language
    │  Decompilation │    Type recovery, variable naming, idiom detection
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │  Code          │  ← Generate C or Python-like output
    │  Generation    │    Format and emit readable source code
    └────────┬───────┘
             │
             ▼
    High-Level Source Code
```

---

## Core Components

RetDec consists of **39+ modules** organized by functionality. Here are the main components:

### 1. **Binary Format Handling**

#### `fileformat/` (73 source files)
- **Purpose**: Parse and validate binary file formats
- **Supported Formats**: PE, ELF, Mach-O, COFF, Intel HEX, raw binary
- **Key Classes**: `FileFormat`, `PeFormat`, `ElfFormat`, `MachOFormat`
- **Dependencies**: PeLib, ELFIO, TinyXML2

**Example Usage:**
```cpp
#include "retdec/fileformat/file_format/file_format.h"

auto format = createFileFormat("binary.exe");
if (format->isPe()) {
    auto peFormat = std::static_pointer_cast<PeFormat>(format);
    // Access PE-specific information
}
```

#### `pelib/` (16 source files)
- **Purpose**: Low-level PE (Portable Executable) file parsing
- **Features**: Import/export tables, resources, debug info
- **Note**: Modified version with Avast additions (MIT license)

### 2. **Binary to LLVM IR Translation**

#### `bin2llvmir/` (110 source files)
- **Purpose**: Core decompilation engine - lifts machine code to LLVM IR
- **Key Subdirectories**:
  - `analyses/` - Reaching definitions, liveness analysis
  - `optimizations/` - Binary-specific optimizations
  - `providers/` - Architecture-specific calling conventions
  - `utils/` - LLVM IR manipulation utilities

**Architecture Support:**
- x86, x86-64
- ARM, ARM64 (AArch64)
- MIPS, MIPS64
- PowerPC, PowerPC64
- PIC32

**Key Transformations:**
1. **Instruction Lifting**: Machine instructions → LLVM IR
2. **Function Detection**: Identify function boundaries
3. **CFG Recovery**: Reconstruct control flow graph
4. **Calling Convention Detection**: Identify register usage patterns
5. **Idiom Recognition**: Detect common code patterns

**Example Calling Convention Provider:**
```cpp
namespace retdec::bin2llvmir {

class X86CallingConvention : public CallingConvention {
public:
    virtual bool isStackPointer(llvm::Value* val) const override;
    virtual bool isReturnRegister(llvm::Value* val) const override;
    // ...
};

} // namespace
```

#### `capstone2llvmir/` (7 source files)
- **Purpose**: Bridge between Capstone disassembler and LLVM IR
- **Role**: Translates Capstone's instruction representation to LLVM

### 3. **LLVM IR to High-Level Language**

#### `llvmir2hll/` (293 source files - largest component!)
- **Purpose**: Transform LLVM IR into high-level language (C or Python-like)
- **Key Subdirectories**:
  - `analysis/` - Alias analysis, value analysis, def-use chains
  - `graphs/` - Control flow graph (CFG), call graph (CG)
  - `hll/` - High-level language representations
  - `ir/` - Intermediate representation for HLL
  - `optimizer/` - HLL-specific optimizations
  - `pattern/` - Pattern matching for idiom detection
  - `semantics/` - Semantic analysis
  - `var_renamer/` - Variable naming heuristics

**Key Features:**
1. **Type Recovery**: Infer types from usage patterns
2. **Variable Naming**: Generate meaningful variable names
3. **Control Flow Structuring**: Convert gotos to if/while/for
4. **Idiom Detection**: Recognize common patterns (strlen, memcpy, etc.)
5. **C++ Class Reconstruction**: Detect vtables and class hierarchies

**Example Pattern Matcher:**
```cpp
namespace retdec::llvmir2hll {

class StrlenPatternFinder : public PatternFinder {
public:
    virtual bool matchesPattern(const Instruction& inst) const override {
        // Detect strlen() implementation pattern
        // Return true if instruction sequence matches strlen
    }
};

} // namespace
```

### 4. **Common Utilities**

#### `common/` (16 core files)
- **Purpose**: Shared data structures and utilities
- **Key Classes**:
  - `Function` - Function metadata
  - `BasicBlock` - Basic block representation
  - `Object` - Generic object representation
  - `AddressRange` - Memory address ranges
  - `Type` - Type system

**Example:**
```cpp
namespace retdec::common {

class Function : public AddressRange {
public:
    const std::string& getName() const;
    void setName(const std::string& name);
    bool isDecompilerDefined() const;
    CallingConvention getCallingConvention() const;

private:
    std::string _name;
    CallingConvention _callingConvention;
    // ...
};

} // namespace
```

#### `config/` (5 files)
- **Purpose**: Configuration management (JSON-based)
- **Features**: Serialization/deserialization of decompiler settings
- **Dependencies**: RapidJSON

#### `utils/` (16 files)
- **Purpose**: General utility functions
- **Features**: String manipulation, file I/O, logging, conversions

### 5. **Analysis & Detection**

#### `cpdetect/` (9 files)
- **Purpose**: Compiler and packer detection
- **Features**: Identify compiler version, detect packers (UPX, etc.)
- **Method**: Signature matching with YARA rules

#### `unpacker/` (6 files)
- **Purpose**: Unpack compressed/obfuscated binaries
- **Supported**: UPX and other common packers

#### `rtti-finder/` (4 files)
- **Purpose**: C++ RTTI (Runtime Type Information) detection
- **Features**: Extract class hierarchies, vtable structures

#### `stacofin/` (6 files)
- **Purpose**: Static code finder - library function detection
- **Method**: Signature-based matching against known library code

### 6. **Type System**

#### `ctypes/` (10 files)
- **Purpose**: C type system representation
- **Classes**: `IntegralType`, `FloatingPointType`, `PointerType`, `ArrayType`, `StructType`, `FunctionType`

#### `ctypesparser/` (3 files)
- **Purpose**: Parse C type definitions from JSON
- **Use Case**: Import type information from external sources

### 7. **Demangling**

#### `demangler/` (29 files)
- **Purpose**: Demangle C++ symbol names
- **Supported**: GCC, MSVC, Borland mangling schemes
- **Example**: `_Z3foov` → `foo()`

### 8. **Debug Information**

#### `debugformat/` (6 files)
- **Purpose**: Parse debug information (DWARF, PDB)
- **Features**: Extract function names, variable types, source lines

#### `pdbparser/` (4 files)
- **Purpose**: Microsoft PDB (Program Database) parsing
- **Platform**: Windows-specific debug information

### 9. **Serialization**

#### `serdes/` (16 files)
- **Purpose**: Serialization/deserialization of analysis results
- **Format**: JSON
- **Use Case**: Save/load intermediate results

### 10. **YARA Integration**

#### `yaracpp/` (3 files)
- **Purpose**: C++ wrapper for YARA pattern matching library
- **Use Case**: Signature-based detection of packers, compilers, libraries

---

## Data Flow

### Detailed Decompilation Pipeline

```
1. INPUT PHASE
   ├─ Read binary file
   ├─ Detect file format (fileformat::detectFormat)
   └─ Parse headers and sections

2. PREPROCESSING
   ├─ Compiler detection (cpdetect)
   ├─ Packer detection (YARA signatures)
   ├─ Unpacking if needed (unpacker)
   └─ Extract debugging information (DWARF/PDB)

3. DISASSEMBLY
   ├─ Capstone: Disassemble machine code
   ├─ Identify function entry points
   ├─ Build control flow graph (CFG)
   └─ Detect basic blocks

4. BINARY → LLVM IR (bin2llvmir)
   ├─ Lift machine instructions to LLVM IR
   ├─ Detect calling conventions
   ├─ Recover function signatures
   ├─ Apply binary-specific optimizations
   └─ Generate LLVM IR module

5. LLVM OPTIMIZATION
   ├─ Dead code elimination
   ├─ Constant propagation
   ├─ Loop optimizations
   └─ Inline expansion

6. LLVM IR → HIGH-LEVEL (llvmir2hll)
   ├─ Type analysis and recovery
   ├─ Variable renaming
   ├─ Pattern matching (idioms)
   ├─ Control flow structuring
   ├─ C++ class reconstruction (if applicable)
   └─ Generate HLL representation

7. CODE GENERATION
   ├─ Choose output language (C / Python-like)
   ├─ Format code (indentation, comments)
   ├─ Generate function signatures
   └─ Emit final source code

8. OUTPUT PHASE
   ├─ Write source code to file
   ├─ Generate call graphs (optional)
   ├─ Generate control flow graphs (optional)
   └─ Create JSON metadata
```

---

## Module Dependencies

### Dependency Graph (Simplified)

```
retdec-decompiler
    │
    ├──▶ bin2llvmir
    │       ├──▶ capstone2llvmir
    │       │       └──▶ Capstone (external)
    │       ├──▶ debugformat
    │       ├──▶ config
    │       └──▶ common
    │
    ├──▶ llvmir2hll
    │       ├──▶ config
    │       ├──▶ common
    │       └──▶ LLVM (external)
    │
    ├──▶ fileformat
    │       ├──▶ pelib
    │       ├──▶ ELFIO (external)
    │       ├──▶ OpenSSL (external)
    │       └──▶ TLSH (external)
    │
    ├──▶ loader
    │       └──▶ fileformat
    │
    ├──▶ cpdetect
    │       └──▶ fileformat
    │
    └──▶ unpacker
            └──▶ fileformat
```

### External Dependencies

| Dependency | Purpose | Version |
|------------|---------|---------|
| **LLVM** | IR framework & optimizations | Custom fork |
| **Capstone** | Disassembly engine | 5.0.6 |
| **YARA** | Pattern matching | 4.5.5 |
| **OpenSSL** | Cryptography (signature parsing) | 1.1.1+ |
| **RapidJSON** | JSON parsing | Bundled |
| **ELFIO** | ELF format parsing | Bundled |
| **TinyXML2** | XML parsing | Bundled |

---

## Key Algorithms

### 1. Type Recovery

**Challenge**: Binary code has no explicit type information

**Approach**:
1. **Use-Def Analysis**: Track how values are used
2. **Constraint Solving**: Build type constraints from operations
3. **Unification**: Merge constraints to infer types
4. **Refinement**: Iteratively improve type precision

**Example**:
```
// Binary: mov eax, [ebx]
// Initial: eax = load i32* %ebx
// After type analysis: int32_t var = *ptr;
```

### 2. Control Flow Structuring

**Challenge**: Binary uses gotos, need if/while/for

**Approach**:
1. **Identify loops**: Detect back edges in CFG
2. **Classify conditionals**: if-then-else vs. switch
3. **Structure regions**: Apply structuring transformations
4. **Eliminate gotos**: Replace with structured constructs

**Algorithm**: Modified "Sharir's Algorithm" for reducible CFGs

### 3. Function Signature Recovery

**Challenge**: Determine parameter types and count

**Approach**:
1. **Calling convention detection**: Identify ABI (x86 cdecl, stdcall, etc.)
2. **Register analysis**: Track which registers are used
3. **Stack analysis**: Detect stack frame setup
4. **Type inference**: Apply type recovery to parameters

### 4. Idiom Recognition

**Challenge**: Detect library functions (strlen, memcpy, etc.)

**Approach**:
1. **Pattern database**: Maintain library of known patterns
2. **Structural matching**: Match instruction sequences
3. **Semantic equivalence**: Verify behavior matches
4. **Signature matching**: YARA-based detection

---

## Extension Points

RetDec is designed to be extensible. Here are the main extension points:

### 1. Custom Architecture Support

To add a new architecture:

1. **Implement Calling Convention Provider** (`bin2llvmir/providers/`)
   ```cpp
   class MyArchCallingConvention : public CallingConvention {
       // Implement architecture-specific calling convention
   };
   ```

2. **Add Capstone Support** (if not already present)

3. **Register with Factory**:
   ```cpp
   registerCallingConvention("myarch", std::make_unique<MyArchCallingConvention>());
   ```

### 2. Custom Output Format

To add a new output language:

1. **Implement HLL Writer** (`llvmir2hll/hll/`)
   ```cpp
   class MyLanguageWriter : public HLLWriter {
   public:
       virtual void emit(const Module& module) override;
   };
   ```

2. **Register with Factory**:
   ```cpp
   HLLWriterFactory::registerWriter("mylang", MyLanguageWriter::create);
   ```

### 3. Custom Analysis Pass

To add a new analysis:

1. **Implement LLVM Pass** (`bin2llvmir/analyses/`)
   ```cpp
   class MyAnalysisPass : public llvm::ModulePass {
   public:
       virtual bool runOnModule(llvm::Module& M) override;
   };
   ```

2. **Register Pass**:
   ```cpp
   static RegisterPass<MyAnalysisPass> X("my-analysis", "My Analysis Pass");
   ```

### 4. Custom Optimization

To add a new optimization:

1. **Implement Optimizer** (`llvmir2hll/optimizer/`)
   ```cpp
   class MyOptimizer : public Optimizer {
   public:
       virtual void optimize(Module& module) override;
   };
   ```

---

## Development Guide

### Building from Source

See [README.md](README.md) for detailed build instructions.

**Quick start:**
```bash
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=install -DRETDEC_TESTS=on
make -j$(nproc)
ctest
```

### Adding a New Component

1. **Create directory**: `src/my_component/` and `include/retdec/my_component/`
2. **Add CMakeLists.txt**: Define library and dependencies
3. **Update root CMakeLists.txt**: Add subdirectory
4. **Write tests**: `tests/my_component/`
5. **Document**: Add to this ARCHITECTURE.md

### Code Organization Best Practices

- **Namespace**: All code in `retdec::module_name::`
- **Headers**: Public in `include/retdec/`, private in `src/`
- **Naming**: CamelCase classes, camelCase functions, `_prefixed` private members
- **Documentation**: Doxygen comments for all public APIs
- **Testing**: Unit tests for all new functionality

### Debugging Tips

1. **Enable debug symbols**: `cmake .. -DCMAKE_BUILD_TYPE=Debug`
2. **LLVM IR inspection**: Use `llvm-dis` to view `.bc` files
3. **Logging**: Use `retdec::utils::Logger` for debug output
4. **Intermediate output**: Save LLVM IR between passes for inspection

---

## Architecture Decision Records (ADRs)

### Why LLVM?

**Decision**: Use LLVM as intermediate representation

**Rationale**:
- Industry-standard compiler infrastructure
- Rich optimization passes available
- Well-documented and maintained
- Target-independent representation
- Existing tooling (llvm-dis, opt, etc.)

**Tradeoffs**:
- Large dependency
- Learning curve for LLVM API
- LLVM version compatibility challenges

### Why Multi-Stage Pipeline?

**Decision**: Separate binary → LLVM IR → HLL stages

**Rationale**:
- Separation of concerns (architecture-specific vs. generic)
- Leverage LLVM optimizations between stages
- Easier to debug (inspect intermediate representation)
- Extensibility (can add passes at each stage)

**Tradeoffs**:
- Performance overhead from multiple transformations
- Information loss between stages
- Complexity of maintaining multiple representations

### Why Custom LLVM Fork?

**Decision**: Maintain custom LLVM fork with Avast modifications

**Rationale**:
- Mach-O format fixes not yet upstream
- Stability (pinned version)
- Control over optimization passes

**Tradeoffs**:
- Maintenance burden
- Security patch lag
- Divergence from upstream

---

## Performance Considerations

### Bottlenecks

1. **LLVM IR Generation**: Most expensive phase (CPU-intensive)
2. **Type Analysis**: Complex constraint solving
3. **Pattern Matching**: Large pattern databases

### Optimization Strategies

1. **Parallel Analysis**: Independent functions can be analyzed in parallel
2. **Caching**: Cache analysis results for reuse
3. **Lazy Evaluation**: Defer expensive analyses until needed
4. **Pruning**: Skip dead code early

---

## Security Considerations

**Warning**: RetDec processes **untrusted binary input**. Always run in sandboxed environments.

### Risks

1. **Malformed Binaries**: Can trigger parsing bugs
2. **Resource Exhaustion**: Large binaries can consume excessive memory/CPU
3. **Malicious Patterns**: Crafted binaries designed to exploit decompiler

### Mitigations

1. **Input Validation**: Extensive format validation in `fileformat/`
2. **Resource Limits**: Set memory and time limits
3. **Sandboxing**: Run in containers or VMs
4. **Fuzzing**: Continuous fuzz testing of parsers

See [SECURITY.md](SECURITY.md) for detailed security policy.

---

## Additional Resources

- **[README.md](README.md)**: User-facing documentation
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Contribution guidelines
- **[MODERNIZATION_ROADMAP.md](MODERNIZATION_ROADMAP.md)**: Future development plans
- **[Doxygen Docs](https://retdec-tc.avast.com/repository/download/Retdec_DoxygenBuild/.lastSuccessful/build/doc/doxygen/html/index.html)**: API documentation
- **[Publications](https://retdec.com/publications/)**: Academic papers on RetDec algorithms

---

## Glossary

- **CFG**: Control Flow Graph
- **HLL**: High-Level Language
- **IR**: Intermediate Representation
- **LLVM**: Low Level Virtual Machine
- **RTTI**: Runtime Type Information
- **SSA**: Static Single Assignment
- **YARA**: Yet Another Recursive Acronym (pattern matching tool)

---

**Last Updated**: 2025-11-03

For questions or clarifications, see [CONTRIBUTING.md](CONTRIBUTING.md) for how to get help.
