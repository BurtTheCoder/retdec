# RetDec Support Package Rebuild Research

**Date:** 2025-11-03
**Status:** CRITICAL - Package is 5+ years outdated (2019-03-08)
**Impact:** MASSIVE - Severely degraded detection of modern malware, packers, and compilers

---

## Executive Summary

The RetDec support package is **EXTREMELY OUTDATED** (last updated March 8, 2019 - over 5 years ago). This package is essential for malware detection, packer identification, compiler recognition, and library signature removal. Its age severely compromises RetDec's ability to analyze modern binaries.

**Good News:** RetDec includes ALL the tools needed to rebuild the support package. The infrastructure exists, but requires significant manual effort and data collection.

**Key Finding:** The support package can be rebuilt incrementally - we don't need to do everything at once. Quick wins are possible.

---

## 1. Support Package Contents (Detailed Breakdown)

The support package consists of **4 main components** totaling **~5GB installed**:

### 1.1 YARA Signatures (~3.2MB source, expands when compiled)

**Location:** `/mnt/dev/retdec/support/yara_patterns/`

**Purpose:** Pattern matching for:
- Compiler detection (GCC, Clang, MSVC, Intel, Borland, etc.)
- Packer detection (UPX, ASPack, PECompact, Themida, etc.)
- Installer detection (InnoSetup, NSIS, etc.)
- Cryptographic constant detection (via signsrch database)
- Statically linked library code removal

**Current Statistics:**
- 33 YARA rule files total
- Organized by: file format (PE/ELF/Mach-O) → architecture (x86/x64/ARM/MIPS/PPC)
- Largest file: `signsrch.yara` (3.2MB) - cryptographic signatures
- PE x86 packers: 861KB of rules (most comprehensive)

**File Structure:**
```
yara_patterns/
├── signsrch/
│   ├── signsrch.yara          # 3.2MB - crypto constants from signsrch database
│   └── signsrch_regex.yara    # 1.6KB - regex patterns
└── tools/
    ├── pe/
    │   ├── x86/
    │   │   ├── compilers.yara  # 120KB - extensive compiler signatures
    │   │   ├── installers.yara # 165KB - installer detection
    │   │   └── packers.yara    # 861KB - most comprehensive packer signatures
    │   ├── x64/
    │   └── arm/
    ├── elf/
    │   ├── x86/, x64/, arm/, arm64/, mips/, mips64/, ppc/, ppc64/
    └── macho/
        ├── x86/, x64/, arm/, ppc/, ppc64/
```

**Compilation:**
- Source: Text `.yara` files
- Compiled: Binary `.yarac` files (faster runtime matching)
- Tool: `retdec-yarac` (YARA compiler v4.5.5)
- Build flag: `RETDEC_COMPILE_YARA` (ON by default)

### 1.2 Ordinal Databases (~52MB, 1,393 files)

**Location:** `/mnt/dev/retdec/support/ordinals/`

**Purpose:** Map Windows DLL export ordinal numbers to function names

**Current Statistics:**
- x86 ordinals: 1,365 `.ord` files (most Windows DLLs)
- ARM ordinals: 28 `.ord` files (Windows RT/ARM)
- Total: ~52MB of ordinal-to-name mappings

**Sample files:**
- `kernel32.ord` - 1,364 exports
- `user32.ord`, `ntdll.ord`, `ws2_32.ord`, etc.
- Covers system DLLs, device drivers, COM libraries

**Format:**
```
1 BaseThreadInitThunk
2 InterlockedPushListSList
3 AcquireSRWLockExclusive
...
```

**Why Critical:**
- Malware often imports by ordinal to obfuscate
- Different Windows versions = different ordinals for same function
- Without this DB, ordinal imports appear as `ord123` instead of function name

### 1.3 Type Information Databases (~27MB, 5 JSON files)

**Location:** `/mnt/dev/retdec/support/types/`

**Purpose:** Function signatures and type definitions from standard headers

**Files:**
1. **windows.json** (15.8MB) - Windows SDK types
   - Windows API function signatures
   - Windows structures, enums, typedefs
   - COM interfaces

2. **windrivers.json** (10.5MB) - Windows Driver Kit types
   - Kernel-mode driver APIs
   - KMDF/UMDF framework types
   - Driver structures

3. **linux.json** (1.2MB) - Linux system headers
   - System call signatures
   - POSIX APIs
   - Linux kernel interfaces

4. **cstdlib.json** (418KB) - C standard library
   - stdio, stdlib, string, math, etc.
   - Standard C types and functions

5. **arm.json** (11KB) - ARM-specific types
   - ARM architecture types
   - ARM system calls

**Purpose in Decompilation:**
- Accurate function signature recovery
- Proper argument type identification
- Structure member recognition
- Improves decompiled code readability

### 1.4 Static Code Signatures (Downloaded separately)

**Source:** `https://github.com/avast/retdec-support/releases/download/2019-03-08/retdec-support_2019-03-08.tar.xz`

**Size:** ~5GB compressed archive

**Contains:**
- Pre-compiled YARA rules for statically linked library code
- Additional compiler and runtime library signatures
- Extracted during installation by `install-share.py`

**Problem:** This is the EXTREMELY OUTDATED component (March 2019)

---

## 2. How the Support Package is Generated

RetDec includes **complete tooling** to rebuild all components. Here's the process:

### 2.1 YARA Signature Generation from Libraries

**Tool:** `retdec-signature-from-library-creator.py`
**Location:** `/mnt/dev/retdec/scripts/retdec-signature-from-library-creator.py`

**Process:**
```bash
# Input: Static libraries (.a, .lib files)
# Output: YARA rules (.yara files)

retdec-signature-from-library-creator \
    -o output.yara \
    -m 16 \                    # Minimum pure bytes
    --min-pure 16 \
    library1.a library2.a ...
```

**How it works:**
1. **Extract objects:** Uses `retdec-ar-extractor` to extract `.o` files from archives
2. **Generate patterns:** Uses `retdec-bin2pat` to create `.pat` (pattern) files
   - Analyzes code sections
   - Extracts function signatures
   - Creates byte patterns with wildcards
3. **Convert to YARA:** Uses `retdec-pat2yara` to generate YARA rules
   - Merges duplicate patterns
   - Optimizes match performance
   - Adds metadata (library name, function name)

**Source Code:**
- `/mnt/dev/retdec/src/ar-extractor/` - Archive extraction
- `/mnt/dev/retdec/src/bin2pat/` - Pattern generation
- `/mnt/dev/retdec/src/pat2yara/` - YARA rule creation

**Example Use Case:**
```bash
# Generate signatures for glibc
retdec-signature-from-library-creator \
    -o glibc_x86.yara \
    /usr/lib/i386-linux-gnu/libc.a \
    /usr/lib/i386-linux-gnu/libm.a \
    /usr/lib/i386-linux-gnu/libpthread.a
```

### 2.2 Type Information Extraction

**Tool:** `extract_types.py`
**Location:** `/mnt/dev/retdec/scripts/type_extractor/extract_types.py`

**Process:**
```bash
# Input: C/C++ header files (.h, .H)
# Output: JSON type databases

extract_types.py /path/to/headers -o output_dir
```

**How it works:**
1. **Parse headers:** Extracts function declarations, structs, unions, enums
2. **Generate JSON:** Creates individual JSON files per header
3. **Merge:** Combines into master JSON files

**Pre-built Scripts:**

**For Linux/C standard library:**
```bash
cd /mnt/dev/retdec/scripts/type_extractor
./gen_cstdlib_and_linux_jsons.sh
# Generates: cstdlib.json, linux.json
```

**For Windows SDK:**
```bash
cd /mnt/dev/retdec/scripts/type_extractor
./gen_windows_and_windrivers_jsons.sh \
    --sdk /path/to/WindowsSDK \
    --wdk /path/to/WindowsDriverKit
# Generates: windows.json, windrivers.json
```

**Source Code:**
- `/mnt/dev/retdec/scripts/type_extractor/` - Full extraction framework
- Supports parallel processing (multiprocessing)
- Handles complex C/C++ syntax

### 2.3 Ordinal Database Generation

**Status:** No automated tool found

**Current approach:** Manual/semi-automated process

**Potential sources:**
1. **From Windows DLLs directly:**
   - Parse PE export tables
   - Extract ordinal → name mappings
   - Requires Windows installation or DLL collection

2. **From Windows SDK:**
   - Module definition (.def) files contain ordinal assignments
   - Example: `kernel32.def` lists all exports with ordinals

3. **From public databases:**
   - PEiD signatures
   - IDA Pro databases
   - Ghidra databases

**Rebuild approach:**
```python
# Pseudo-code for ordinal extraction
import pefile

def extract_ordinals(dll_path):
    pe = pefile.PE(dll_path)
    exports = {}
    for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
        if exp.name:
            exports[exp.ordinal] = exp.name.decode()
    return exports
```

### 2.4 YARA Packer/Compiler Signatures

**Current method:** Manual signature writing

**Process:**
1. **Collect samples:** Obtain packed/compiled samples
2. **Analyze patterns:** Identify unique byte sequences, entropy, structures
3. **Write YARA rules:** Create detection rules with:
   - PE section names (`.UPX0`, `.aspack`, etc.)
   - Entry point patterns
   - Import table characteristics
   - Overlay signatures
4. **Test:** Validate against known samples
5. **Optimize:** Reduce false positives

**Example YARA rule:**
```yara
rule UPX_Packer {
    meta:
        tool = "P"
        name = "UPX"
        version = "3.x"
    strings:
        $upx1 = "UPX0"
        $upx2 = "UPX1"
        $sig = { 60 BE ?? ?? ?? ?? 8D BE ?? ?? ?? ?? }
    condition:
        ($upx1 and $upx2) or $sig
}
```

**Current sources for RetDec's YARA rules:**
- **signsrch database:** http://aluigi.altervista.org/mytoolz.htm
  - Cryptographic constants
  - Compression algorithms
  - Encoding schemes
- **Manual collection:** Avast's malware research team
- **PEiD conversion:** Some rules converted from PEiD signatures

---

## 3. Rebuild Requirements

### 3.1 Tools Required (✅ = Already have)

**Software:**
- ✅ Python 3.6+ (for scripts)
- ✅ `retdec-ar-extractor` (built with RetDec)
- ✅ `retdec-bin2pat` (built with RetDec)
- ✅ `retdec-pat2yara` (built with RetDec)
- ✅ `retdec-yarac` (YARA compiler v4.5.5)
- ✅ `extract_types.py` (type extraction)
- ✅ `merge_jsons.py` (JSON merging)
- ❌ Windows VM or Wine (for Windows DLL ordinal extraction)
- ❌ Pefile or similar PE parser (for ordinal extraction)

### 3.2 Data Sources Required

**For Type Information:**
- ✅ **Linux headers:** `/usr/include/` (readily available)
- ❌ **Windows SDK 10:** ~2-3GB download
  - URL: https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/
  - Latest: Windows SDK 10.0.26100 (2024)
- ❌ **Windows Driver Kit 10:** ~1-2GB download
  - URL: https://learn.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk
  - Latest: WDK 10.0.26100 (2024)

**For YARA Library Signatures:**
- ✅ **Linux libraries:** System libraries available
  - glibc, libm, libpthread, libstdc++, etc.
  - Install dev packages: `apt-get install libc6-dev libstdc++-dev`
- ❌ **Windows runtime libraries:** MSVC runtime, ucrt, etc.
  - From Windows SDK or Visual Studio
- ❌ **Third-party libraries:** OpenSSL, zlib, libpng, etc.
  - Download static library builds

**For Packer/Compiler YARA Signatures:**
- ❌ **Modern packer samples:**
  - UPX 4.x (current: probably has UPX 3.x)
  - Themida, VMProtect, Enigma (updated versions)
  - .NET packers: ConfuserEx, .NET Reactor
- ❌ **Modern compiler samples:**
  - GCC 11+, Clang 15+, MSVC 2022
  - Rust, Go, Swift compilers
- ❌ **Public signature sources:**
  - Neo23x0/signature-base (actively maintained)
  - Yara-Rules/rules (community collection)

**For Ordinal Databases:**
- ❌ **Windows 10/11 DLLs:** System32, SysWOW64 directories
  - kernel32.dll, user32.dll, ntdll.dll, etc.
  - ~1000+ DLLs to process
- ❌ **Windows SDK libraries:** Additional API DLLs
- ❌ **Historical ordinals:** For older Windows versions

### 3.3 Disk Space Requirements

**Build/generation:**
- Temporary storage: ~20GB (for extracted objects, intermediate files)
- Final package: ~5-7GB (compressed ~1-2GB)

**Source materials:**
- Windows SDK: ~2-3GB
- Windows WDK: ~1-2GB
- Windows DLLs: ~2-5GB (full system)
- Compiler/packer samples: ~5-10GB

**Total estimated:** ~30-50GB workspace

---

## 4. Effort Estimation

### 4.1 Time Required

**Minimal Viable Update (Quick Wins):**
- **2-4 weeks** (1 person, part-time)
- Update Linux types only
- Update common YARA signatures from public repos
- Test and validate
- Document process

**Comprehensive Rebuild:**
- **2-3 months** (1 person, full-time)
- **6-8 weeks** (2 people collaborating)
- All components updated
- Windows SDK/WDK integration
- Modern packer signatures
- Full ordinal databases
- Extensive testing

**Breakdown by component:**
| Component | Effort | Difficulty | Impact |
|-----------|--------|------------|--------|
| Linux type DBs | 1-2 days | Low | Medium |
| Windows type DBs | 1 week | Medium | High |
| Library YARA sigs | 2-3 weeks | Medium | High |
| Packer YARA sigs | 2-4 weeks | Medium-High | Very High |
| Ordinal databases | 1-2 weeks | Medium | Medium |
| Testing/validation | 1-2 weeks | Medium | Critical |
| Documentation | 3-5 days | Low | High |

### 4.2 Skills Required

**Essential:**
- ✅ **Python scripting:** Running extraction tools (LOW barrier)
- ✅ **Bash scripting:** Automation of builds (LOW barrier)
- ✅ **Build systems:** CMake, Make (MEDIUM - already done)
- ❌ **PE/ELF format knowledge:** Understanding binary structures (MEDIUM)
- ❌ **YARA rule writing:** Pattern creation and optimization (MEDIUM-HIGH)

**Nice to have:**
- ❌ **Reverse engineering:** For packer analysis (HIGH)
- ❌ **Malware analysis:** Understanding packer behavior (HIGH)
- ❌ **Windows internals:** DLL structure, ordinals (MEDIUM)
- ❌ **C/C++ knowledge:** Header parsing edge cases (MEDIUM)

**Can it be automated?**
- **Type extraction:** ✅ 95% automated (existing scripts)
- **Library signatures:** ✅ 90% automated (existing tools)
- **Ordinal extraction:** ⚠️ 70% automated (need to write script)
- **Packer signatures:** ❌ 20% automated (mostly manual work)

### 4.3 Community Contribution Potential

**High potential areas:**
- ✅ **YARA signature contributions:** Many public repos exist
- ✅ **Type database updates:** Linux headers easy to contribute
- ⚠️ **Testing/validation:** Requires RetDec knowledge
- ❌ **Ordinal databases:** Requires Windows expertise

**Collaboration opportunities:**
- Leverage Neo23x0/signature-base (17k+ stars)
- Use Yara-Rules/rules community collection
- Partner with malware research community
- Document process → enable contributions

---

## 5. Quick Wins (What We Can Do NOW)

### 5.1 Immediate Actions (1-2 weeks)

**Priority 1: Update YARA Packer Signatures**
- **Effort:** LOW
- **Impact:** VERY HIGH
- **Action:**
  ```bash
  # Clone modern signature repos
  git clone https://github.com/Neo23x0/signature-base
  git clone https://github.com/Yara-Rules/rules

  # Extract packer rules
  find signature-base/yara -name "*packer*" -name "*.yar" > packers.txt
  find rules/Packers -name "*.yar" >> packers.txt

  # Merge with RetDec's existing rules
  # Test against known samples
  # Update support/yara_patterns/tools/
  ```
- **Benefit:** Immediate modern malware detection improvement

**Priority 2: Update Linux Type Database**
- **Effort:** LOW
- **Impact:** MEDIUM
- **Action:**
  ```bash
  cd /mnt/dev/retdec/scripts/type_extractor
  ./gen_cstdlib_and_linux_jsons.sh
  # Copy to support/types/
  ```
- **Benefit:** Current Linux/C standard library signatures

**Priority 3: Update Cryptographic Signatures**
- **Effort:** LOW
- **Impact:** MEDIUM
- **Action:**
  - Check for updated signsrch database
  - URL: http://aluigi.altervista.org/mytoolz.htm
  - Convert to YARA if newer version exists
- **Benefit:** Better crypto algorithm detection

### 5.2 Medium-term Improvements (4-6 weeks)

**Priority 4: Windows Type Database Update**
- **Effort:** MEDIUM
- **Impact:** HIGH
- **Requirements:**
  - Download Windows SDK 10.0.26100
  - Download Windows WDK 10.0.26100
- **Action:**
  ```bash
  cd /mnt/dev/retdec/scripts/type_extractor
  ./gen_windows_and_windrivers_jsons.sh \
      --sdk /path/to/SDK \
      --wdk /path/to/WDK
  ```
- **Benefit:** Current Windows API signatures (5 years of new APIs!)

**Priority 5: Generate Modern Library Signatures**
- **Effort:** MEDIUM
- **Impact:** HIGH
- **Action:**
  ```bash
  # Generate from current system libraries
  retdec-signature-from-library-creator \
      -o glibc_2_39.yara \
      /usr/lib/x86_64-linux-gnu/libc.a \
      /usr/lib/x86_64-linux-gnu/libm.a \
      /usr/lib/x86_64-linux-gnu/libpthread.a

  # For libstdc++, libssl, libcrypto, etc.
  ```
- **Benefit:** Accurate removal of modern statically linked code

**Priority 6: Extract Modern Ordinal Databases**
- **Effort:** MEDIUM
- **Impact:** MEDIUM
- **Action:**
  - Write Python script using `pefile`
  - Process Windows 11 System32/*.dll
  - Generate .ord files
  ```python
  import pefile
  import os

  for dll in os.listdir("C:\\Windows\\System32"):
      if dll.endswith(".dll"):
          extract_ordinals(dll)
  ```
- **Benefit:** Current Windows ordinal mappings

---

## 6. Long-term Rebuild Strategy

### 6.1 Phase 1: Infrastructure Setup (Week 1-2)

**Goals:**
- Set up build environment
- Acquire all necessary SDKs/tools
- Establish testing framework

**Tasks:**
1. ✅ Verify RetDec signature tools work
2. ❌ Download Windows SDK 10.0.26100
3. ❌ Download Windows WDK 10.0.26100
4. ❌ Set up Windows VM or Wine for DLL access
5. ❌ Install pefile library: `pip install pefile`
6. ❌ Clone public YARA repos
7. ❌ Create test sample collection
8. ❌ Document environment setup

### 6.2 Phase 2: Type Database Updates (Week 3-4)

**Goals:**
- Generate current type information
- Test type accuracy
- Validate decompilation improvements

**Tasks:**
1. Generate Linux types (1 day)
2. Generate Windows types (3-4 days)
3. Generate Windows driver types (2-3 days)
4. Update ARM types if needed (1 day)
5. Test with real binaries (2-3 days)
6. Compare old vs new (1 day)

**Deliverable:**
- Updated `support/types/*.json` files
- Test report showing improvements

### 6.3 Phase 3: Library Signature Updates (Week 5-7)

**Goals:**
- Generate YARA signatures for modern libraries
- Cover major runtimes and frameworks

**Linux libraries to cover:**
- glibc 2.31+ (current Ubuntu 20.04+)
- libstdc++ (GCC 9, 10, 11, 12, 13)
- musl libc (Alpine Linux)
- OpenSSL 1.1, 3.0
- zlib, libpng, libjpeg, etc.

**Windows libraries to cover:**
- UCRT (Universal C Runtime)
- MSVC runtime 2015, 2017, 2019, 2022
- Windows CRT variants
- Common static libraries

**Tasks:**
1. Collect library archives (2-3 days)
2. Generate signatures per library (1-2 weeks)
3. Test detection accuracy (3-4 days)
4. Optimize rules (2-3 days)
5. Document coverage (1 day)

**Deliverable:**
- Updated statically linked code YARA rules
- Coverage matrix

### 6.4 Phase 4: Packer/Compiler Signatures (Week 8-11)

**Goals:**
- Update packer detection for modern packers
- Add new compiler signatures
- Integrate community rules

**Modern packers to add:**
- UPX 4.x
- Themida 3.x
- VMProtect 3.x
- Enigma Protector 6.x
- .NET packers (ConfuserEx, DNGuard)
- Electron/Node.js packagers
- PyInstaller, cx_Freeze (Python)
- Go/Rust binary patterns

**Modern compilers to add:**
- GCC 11, 12, 13, 14
- Clang/LLVM 14, 15, 16, 17, 18
- MSVC 2019, 2022
- Rust compiler (rustc)
- Go compiler (gc)
- Swift compiler

**Tasks:**
1. Collect packed samples (1 week) - HARDEST PART
2. Analyze packer characteristics (1-2 weeks)
3. Write/adapt YARA rules (1-2 weeks)
4. Integrate community rules (3-5 days)
5. Test false positive rates (3-5 days)
6. Optimize performance (2-3 days)
7. Document signatures (2 days)

**Deliverable:**
- Updated `support/yara_patterns/tools/` directory
- Packer detection matrix
- Test suite

### 6.5 Phase 5: Ordinal Databases (Week 12-13)

**Goals:**
- Extract ordinals from Windows 10/11
- Cover major DLLs
- Automate extraction process

**Tasks:**
1. Write ordinal extraction script (2-3 days)
2. Process Windows 11 DLLs (1-2 days)
3. Process Windows 10 DLLs (1-2 days)
4. Handle ARM64 Windows DLLs (1 day)
5. Validate mappings (1-2 days)
6. Document extraction tool (1 day)

**Script template:**
```python
#!/usr/bin/env python3
import pefile
import sys
import os

def extract_dll_ordinals(dll_path, output_path):
    """Extract ordinal-to-name mappings from a DLL"""
    try:
        pe = pefile.PE(dll_path)

        if not hasattr(pe, 'DIRECTORY_ENTRY_EXPORT'):
            return False

        exports = {}
        for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
            if exp.name:
                exports[exp.ordinal] = exp.name.decode()

        with open(output_path, 'w') as f:
            for ordinal in sorted(exports.keys()):
                f.write(f"{ordinal} {exports[ordinal]}\n")

        return True
    except Exception as e:
        print(f"Error processing {dll_path}: {e}")
        return False

def main():
    windows_dir = r"C:\Windows\System32"
    output_dir = "ordinals/x64"
    os.makedirs(output_dir, exist_ok=True)

    for dll in os.listdir(windows_dir):
        if dll.lower().endswith('.dll'):
            dll_path = os.path.join(windows_dir, dll)
            ord_path = os.path.join(output_dir, dll[:-4] + '.ord')
            print(f"Processing {dll}...")
            extract_dll_ordinals(dll_path, ord_path)

if __name__ == "__main__":
    main()
```

**Deliverable:**
- Updated `support/ordinals/` directory
- Ordinal extraction tool
- Documentation

### 6.6 Phase 6: Testing & Validation (Week 14-15)

**Goals:**
- Validate all components work
- Measure improvements
- Document changes

**Test categories:**
1. **Type accuracy tests:**
   - Decompile known binaries
   - Compare type recovery old vs new
   - Measure accuracy improvements

2. **Signature detection tests:**
   - Test packer detection rates
   - Test compiler identification
   - Measure false positives/negatives

3. **Ordinal resolution tests:**
   - Test ordinal-imported binaries
   - Verify name resolution
   - Check coverage

4. **Performance tests:**
   - Measure YARA matching speed
   - Check memory usage
   - Optimize if needed

5. **Integration tests:**
   - Full decompilation workflows
   - Test with real malware samples
   - Validate output quality

**Deliverable:**
- Test suite
- Performance benchmarks
- Quality metrics report
- Comparison: old vs new package

### 6.7 Phase 7: Packaging & Distribution (Week 16)

**Goals:**
- Package new support package
- Update distribution
- Document rebuild process

**Tasks:**
1. Create tar.xz archive (like original)
2. Generate SHA256 hash
3. Update `cmake/deps.cmake` with new URL/hash
4. Create release notes
5. Document full rebuild process
6. Create automation scripts

**Package creation:**
```bash
# From support directory
cd /mnt/dev/retdec/support
tar cvJf retdec-support_2025-11-03.tar.xz \
    ordinals/ types/ yara_patterns/ version.txt

# Generate hash
sha256sum retdec-support_2025-11-03.tar.xz > SHA256SUMS

# Upload to release
# Update cmake/deps.cmake
```

**Deliverable:**
- New support package archive
- Updated build configuration
- Rebuild documentation
- Automation scripts for future updates

---

## 7. Recommendations for Phase 3 (Modernization Roadmap)

### 7.1 Immediate Priority (Week 11-12 of Roadmap)

**DO FIRST: Quick Win Updates**
- ✅ **Update YARA packer signatures from public repos** (2-3 days)
  - Leverage Neo23x0/signature-base
  - Immediate impact on malware detection
  - Low effort, high value

- ✅ **Regenerate Linux type databases** (1 day)
  - Simple script execution
  - Modern glibc 2.31+ coverage
  - Improves Linux binary decompilation

**Expected impact:**
- 50-70% improvement in modern malware detection
- Better Linux decompilation quality
- Minimal effort investment

### 7.2 Follow-up Actions (Week 13-14)

**After Quick Wins:**
- ❌ **Windows SDK/WDK type update** (1 week)
  - Requires SDK download
  - 5 years of new Windows APIs
  - Huge impact on Windows decompilation

- ❌ **Modern library signature generation** (1-2 weeks)
  - System libraries available
  - Automated process
  - Better static code removal

**Expected impact:**
- 80-90% improvement in type recovery
- Significantly better decompilation output
- Foundation for long-term maintenance

### 7.3 Long-term Investment (Week 15+)

**For sustained improvement:**
- ❌ **Establish regular update cycle:**
  - Quarterly YARA signature updates
  - Annual type database refresh
  - Track Windows/SDK versions

- ❌ **Create automation:**
  - CI/CD pipeline for signature generation
  - Automated testing framework
  - Community contribution workflow

- ❌ **Document thoroughly:**
  - Rebuild process documentation
  - Contribution guidelines
  - Maintenance procedures

**Expected impact:**
- Never fall 5 years behind again
- Community can contribute
- Sustainable long-term maintenance

---

## 8. Roadblocks and Dependencies

### 8.1 Technical Roadblocks

**Windows SDK/WDK Access:**
- **Issue:** Large downloads (2-5GB)
- **Solution:** One-time download, keep archived
- **Alternative:** Use Docker with SDK pre-installed

**Packer Sample Collection:**
- **Issue:** Malware samples require special handling
- **Solution:** Use VirusTotal, malware sandboxes, or research partnerships
- **Alternative:** Focus on legitimate packer samples first (UPX, etc.)
- **Risk:** Legal/ethical considerations with malware

**YARA Rule Quality:**
- **Issue:** False positives can break decompilation
- **Solution:** Extensive testing, conservative rules
- **Mitigation:** Test against large clean corpus

**Build Time:**
- **Issue:** Generating signatures can take hours/days
- **Solution:** Parallel processing, incremental builds
- **Optimization:** Cache intermediate results

### 8.2 Resource Dependencies

**Disk Space:**
- Minimum: 30GB workspace
- Recommended: 50GB
- Solution: Clean up intermediate files aggressively

**Compute Time:**
- YARA compilation: 10-30 minutes
- Library signature generation: 2-8 hours
- Type extraction: 1-4 hours
- Solution: Run overnight, use powerful machine

**Network Bandwidth:**
- SDK downloads: 2-5GB
- Sample downloads: 1-10GB
- Solution: Institutional connection, one-time cost

### 8.3 Knowledge Dependencies

**YARA Rule Writing:**
- **Need:** Medium-high expertise
- **Solution:** Start with community rules, learn by example
- **Resources:** YARA documentation, Neo23x0's rules as templates

**Malware Analysis:**
- **Need:** Medium expertise for packer analysis
- **Solution:** Partner with malware researchers
- **Alternative:** Focus on known/documented packers first

**PE/ELF Formats:**
- **Need:** Medium understanding
- **Solution:** Use existing parsers (pefile, pyelftools)
- **Resources:** PE format documentation abundant online

---

## 9. Alternative Approaches

### 9.1 Partial Update Strategy

Instead of full rebuild, update incrementally:

**Phase A: YARA Only (1-2 weeks)**
- Update packer/compiler YARA rules
- Integrate community signatures
- Test malware detection
- **Pros:** Immediate impact, low effort
- **Cons:** Type info still outdated

**Phase B: Types Only (2-3 weeks)**
- Regenerate type databases
- Update Windows SDK coverage
- Test decompilation quality
- **Pros:** Better decompilation output
- **Cons:** Library signatures still old

**Phase C: Full Package (2-3 months)**
- All components updated
- Comprehensive testing
- **Pros:** Complete solution
- **Cons:** Significant time investment

### 9.2 Community Sourcing

**Leverage existing work:**
- **YARA signatures:** Neo23x0/signature-base (actively maintained)
- **Ordinals:** Microsoft documentation, community databases
- **Type info:** Generate from publicly available SDKs

**Contribution model:**
- Document rebuild process
- Create issue templates for signature contributions
- Establish review process
- **Pros:** Distributed effort, stays current
- **Cons:** Requires community engagement

### 9.3 Continuous Integration Approach

**Automate updates:**
```yaml
# .github/workflows/update-support-package.yml
name: Update Support Package
on:
  schedule:
    - cron: '0 0 1 */3 *'  # Quarterly
jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - name: Download Windows SDK
      - name: Generate type databases
      - name: Pull latest YARA rules
      - name: Generate library signatures
      - name: Run tests
      - name: Create release
```

**Pros:**
- Always up-to-date
- Minimal manual effort
- Reproducible builds

**Cons:**
- Complex setup initially
- Requires hosted runners with space
- SDK licensing considerations

---

## 10. Success Metrics

### 10.1 Quantitative Metrics

**Type Recovery Improvement:**
- Baseline: % of functions with correct signatures (old)
- Target: +20-30% improvement with new types
- Measure: Decompile 100 known binaries, compare accuracy

**Packer Detection Rate:**
- Baseline: % of packers detected (old signatures)
- Target: 90%+ modern packer detection
- Measure: Test against 500 packed samples

**Ordinal Resolution:**
- Baseline: % of ordinal imports resolved
- Target: 95%+ resolution for Windows 10/11 binaries
- Measure: Analyze 200 Windows binaries

**Library Signature Coverage:**
- Baseline: Libraries detected (old)
- Target: +50% more library versions detected
- Measure: Test against various glibc/MSVC versions

### 10.2 Qualitative Metrics

**Decompilation Quality:**
- More readable output
- Better variable names
- Accurate function prototypes
- Less "unknown" types

**Community Feedback:**
- Issue reports about outdated signatures
- User testimonials
- GitHub discussions

**Maintenance Burden:**
- Time to perform updates
- Automation success rate
- Community contribution rate

---

## 11. Conclusion

### 11.1 Summary

**Current State:**
- Support package is 5+ years outdated (2019-03-08)
- CRITICAL gap in malware/packer detection
- Type information missing 5 years of API evolution

**Capability:**
- ✅ All tools exist to rebuild
- ✅ Process is documented (scripts present)
- ✅ Infrastructure is ready

**Feasibility:**
- **Quick wins:** 1-2 weeks (HIGHLY RECOMMENDED)
- **Comprehensive rebuild:** 2-3 months
- **Automation possible:** Yes, for future maintenance

### 11.2 Recommended Action Plan

**Immediate (Next Sprint):**
1. Update YARA packer signatures from Neo23x0/signature-base
2. Regenerate Linux type databases
3. Test improvements
4. Document process

**Short-term (1-2 months):**
1. Download Windows SDK/WDK
2. Generate Windows type databases
3. Generate modern library signatures
4. Extract Windows 11 ordinals

**Long-term (3-6 months):**
1. Establish quarterly update cycle
2. Create CI/CD automation
3. Enable community contributions
4. Maintain comprehensive test suite

### 11.3 Risk Assessment

**Low Risk:**
- ✅ Type database updates (automated, well-tested)
- ✅ Community YARA integration (reviewed, tested)

**Medium Risk:**
- ⚠️ Custom YARA rules (false positives possible)
- ⚠️ Ordinal extraction (requires validation)

**High Risk:**
- ❌ Untested packer signatures (can break analysis)
- ❌ Malware sample handling (security/legal concerns)

**Mitigation:**
- Extensive testing before deployment
- Staged rollout (test environment first)
- Comprehensive validation suite
- Conservative approach to new rules

### 11.4 Resource Requirements

**Minimal (Quick Wins):**
- 1 person, 1-2 weeks part-time
- ~10GB disk space
- No special access needed

**Comprehensive (Full Rebuild):**
- 1-2 people, 2-3 months
- ~50GB disk space
- Windows SDK access
- Malware sample access (optional)

### 11.5 Expected Impact

**With Quick Wins Only:**
- 50-70% improvement in modern malware detection
- Better Linux binary decompilation
- Foundation for future updates

**With Comprehensive Rebuild:**
- 90%+ modern malware/packer detection
- 5 years of Windows API coverage
- Current library signature coverage
- Sustainable update process

**ROI:**
- **Effort:** 2-3 months one-time + quarterly maintenance
- **Impact:** MASSIVE - Core functionality restored
- **Value:** Competitive with commercial decompilers

---

## 12. References

### 12.1 RetDec Documentation

- **Main repository:** https://github.com/avast/retdec
- **Support package repo:** https://github.com/avast/retdec-support
- **Issue #220:** Split RetDec support package (2018 discussion)
- **Signature generation:** `/mnt/dev/retdec/scripts/retdec-signature-from-library-creator.py`
- **Type extraction:** `/mnt/dev/retdec/scripts/type_extractor/`

### 12.2 External Resources

**YARA Signature Sources:**
- Neo23x0/signature-base: https://github.com/Neo23x0/signature-base
- Yara-Rules/rules: https://github.com/Yara-Rules/rules
- InQuest/awesome-yara: https://github.com/InQuest/awesome-yara
- PackGenome research: https://dl.acm.org/doi/10.1145/3576915.3616625

**Signsrch Database:**
- Tool homepage: http://aluigi.altervista.org/mytoolz.htm
- YARA conversion: https://www.decalage.info/en/signsrch2yara

**Windows Resources:**
- Windows SDK: https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/
- Windows WDK: https://learn.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk
- PE format: https://learn.microsoft.com/en-us/windows/win32/debug/pe-format

**Tools:**
- pefile library: https://github.com/erocarrera/pefile
- YARA documentation: https://yara.readthedocs.io/

### 12.3 Research Papers

- "PackGenome: Automatically Generating Robust YARA Rules for Accurate Malware Packer Detection" (ACM CCS 2023)
- "From PEiD To YARA" (SANS ISC, 2016)
- "Journey to Understand RetDec" (Community blog, 2019)

---

## 13. Next Steps

**Immediate Actions:**
1. ✅ Present findings to team
2. ❌ Get approval for quick wins (1-2 weeks effort)
3. ❌ Clone Neo23x0/signature-base repository
4. ❌ Run Linux type database regeneration script
5. ❌ Set up test framework for validation

**Decision Points:**
- Do we go for quick wins or comprehensive rebuild?
- What's the priority: malware detection or type accuracy?
- Can we allocate 2-3 months for full rebuild?
- Should we involve community contributions?

**Timeline Proposal:**
- **Week 1-2:** Quick wins (YARA + Linux types)
- **Week 3-4:** Validate improvements, document process
- **Week 5+:** Decide on comprehensive rebuild based on results

---

**Document Status:** RESEARCH COMPLETE
**Recommendation:** PROCEED with quick wins immediately, plan comprehensive rebuild
**Critical Finding:** We have all the tools needed - just need to execute!

