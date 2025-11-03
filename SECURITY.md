# Security Policy

## Reporting Security Vulnerabilities

We take the security of RetDec seriously. If you believe you have found a security vulnerability, please report it to us responsibly.

**Please use [this submission form](https://www.nortonlifelock.com/us/en/contact-us/report-a-security-vulnerability/) to report any (potential) security vulnerabilities.**

When reporting, please provide as much detail as possible, including:
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Any suggested fixes (if applicable)
- Your contact information for follow-up

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 7 business days
- **Updates**: We will keep you informed of our progress
- **Credit**: We will credit you for the discovery (unless you prefer to remain anonymous)

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 5.0.x   | :white_check_mark: | Active |
| < 5.0   | :x:                | End of Life |

## Security Update Policy

### Response Times

- **Critical Vulnerabilities**: Patched within 7 days, emergency release if needed
- **High Severity**: Patched within 30 days
- **Medium Severity**: Patched in next scheduled release
- **Low Severity**: Addressed when convenient

### Severity Levels

**Critical**:
- Remote code execution
- Privilege escalation
- Authentication bypass
- Data breach potential

**High**:
- Denial of service
- Information disclosure
- Security feature bypass

**Medium**:
- Cross-site scripting (if web interfaces exist)
- Memory leaks
- Improper input validation

**Low**:
- Minor information disclosure
- Non-security bugs with minor security implications

## Known Security Considerations

### Binary Analysis Risks

RetDec processes potentially **untrusted binary input** (executables, libraries, etc.). When analyzing unknown or untrusted binaries:

1. **Always run in a sandboxed environment**
   - Use containers (Docker) or virtual machines
   - Limit file system access
   - Restrict network access

2. **Resource Limits**
   - Set memory limits (malicious files can cause excessive memory usage)
   - Set CPU time limits
   - Monitor disk usage

3. **Input Validation**
   - RetDec includes input validation, but no guarantees for malformed binaries
   - Malicious crafted binaries could trigger bugs

### Dependencies

RetDec relies on several third-party libraries. We monitor these dependencies for security issues:

- **LLVM**: Custom fork based on upstream (security patches applied)
- **Capstone**: Disassembly engine (keep updated)
- **YARA**: Pattern matching (keep updated)
- **OpenSSL**: Cryptography library (system version required >= 1.1.1)

**Recommendation**: Keep your system's OpenSSL and other dependencies updated.

### Build Security

When building RetDec from source:

1. **Verify checksums**: Our build system verifies SHA256 hashes for downloaded dependencies
2. **Use official sources**: Clone from official GitHub repository
3. **Check signatures**: Verify git commit signatures when available

## Security Best Practices for Users

### When Using RetDec

1. **Isolate Analysis Environment**
   ```bash
   # Example: Run in Docker container
   docker run --rm -v /path/to/binaries:/data retdec retdec-decompiler /data/binary
   ```

2. **Limit Permissions**
   - Run as non-root user
   - Use read-only file systems where possible
   - Apply principle of least privilege

3. **Monitor Resources**
   - Watch for excessive memory usage
   - Set timeouts for long-running analysis
   - Monitor CPU usage

4. **Validate Output**
   - Review decompiled code carefully
   - Don't execute decompiled code without review
   - Be aware of potential malicious patterns

### For Developers Contributing to RetDec

1. **Code Security**
   - Avoid unsafe C++ constructs (prefer smart pointers)
   - Validate all external input
   - Use RAII for resource management
   - Bounds check all array accesses

2. **Testing**
   - Include security test cases
   - Test with malformed inputs
   - Fuzz test when possible

3. **Static Analysis**
   - Code is checked with clang-tidy
   - CodeQL security scanning enabled
   - Address compiler warnings

## Security Scanning

RetDec employs the following automated security measures:

- **CodeQL Analysis**: Weekly automated scans for security vulnerabilities
- **Dependabot**: Monitors GitHub Actions dependencies
- **Static Analysis**: clang-tidy checks on all pull requests
- **Compiler Warnings**: Enabled and monitored (except MSVC currently)

## Disclosure Policy

We follow **coordinated disclosure**:

1. Vulnerability reported to us
2. We investigate and develop fix
3. Fix is released
4. Public disclosure (typically 90 days after fix, or sooner if already public)

We will credit security researchers unless they prefer anonymity.

## Security Contacts

- **Primary**: Use [vulnerability submission form](https://www.nortonlifelock.com/us/en/contact-us/report-a-security-vulnerability/)
- **GitHub**: For non-critical security discussions, use [GitHub Security Advisories](https://github.com/avast/retdec/security/advisories)

## Security-Related Documentation

- Build security: See [README.md](README.md) for verified build process
- Contributing: See [CONTRIBUTING.md](CONTRIBUTING.md) for code quality guidelines
- Dependencies: See [DEPENDENCY_ANALYSIS.md](DEPENDENCY_ANALYSIS.md) for dependency security info

## Updates to This Policy

This security policy may be updated from time to time. Check back regularly for changes.

**Last Updated**: 2025-11-03

---

Thank you for helping keep RetDec and its users safe!
