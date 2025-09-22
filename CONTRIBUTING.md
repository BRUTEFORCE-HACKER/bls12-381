# Contributing to BLS12-381 Signature Library

[![Standards](https://img.shields.io/badge/code_standards-extremely_high-red.svg?style=plastic)](#code-standards)
[![Quality](https://img.shields.io/badge/quality-enterprise_grade-green.svg?style=plastic)](#quality-requirements)
[![Review Process](https://img.shields.io/badge/review_process-rigorous-blue.svg?style=plastic)](#review-process)

> **⚠️ IMPORTANT**: This project maintains **extremely high standards** for code quality, consistency, and correctness. Contributions that do not meet these standards will be rejected immediately. Please read this document carefully and follow every guideline precisely.

We welcome contributions to the BLS12-381 signature library, but only those that meet our exacting standards for **production-grade cryptographic software**. This is not a hobby project - it's enterprise-grade cryptographic infrastructure that demands perfection.

## 📋 Table of Contents

- [Quality Philosophy](#quality-philosophy)
- [Before You Begin](#before-you-begin)
- [Code Standards](#code-standards)
- [File Organization](#file-organization)
- [Documentation Requirements](#documentation-requirements)
- [Testing Requirements](#testing-requirements)
- [Performance Requirements](#performance-requirements)
- [Commit Standards](#commit-standards)
- [Pull Request Process](#pull-request-process)
- [Review Criteria](#review-criteria)
- [Rejected Contribution Examples](#rejected-contribution-examples)

## 🎯 Quality Philosophy

This project follows the **"Zero Tolerance for Mediocrity"** principle:

- **Every line matters** - Sloppy code anywhere affects the entire codebase
- **Consistency is king** - Deviations from established patterns are not tolerated
- **Documentation is mandatory** - Undocumented code is broken code
- **Performance is non-negotiable** - Regressions will be rejected
- **Security comes first** - Memory safety and cryptographic correctness are paramount

**If you're not prepared to meet these standards, please reconsider contributing.**

## 🚀 Before You Begin

### Prerequisites

1. **Deep Zig Knowledge Required**
   - Mastery of Zig 0.15.1+ language features
   - Understanding of memory management and safety
   - Experience with systems programming concepts
   - Familiarity with cryptographic principles

2. **Development Environment**
   ```bash
   # Exact versions required
   zig version     # Must be 0.15.1+
   git --version   # 2.34.0+
   
   # Required tools
   zig fmt         # For code formatting
   zig build test  # For testing
   zig build bench # For performance validation
   ```

3. **Read These First**
   - [Zig Style Guide](https://ziglang.org/documentation/master/#Style-Guide) (follow religiously)
   - [BLS12-381 Specification](https://datatracker.ietf.org/doc/draft-irtf-cfrg-bls-signature/)
   - [Ethereum 2.0 BLS Requirements](https://github.com/ethereum/consensus-specs/)
   - This entire CONTRIBUTING.md (every word)

## 💎 Code Standards

### File Structure Requirements

**Every `.zig` file MUST start with this exact header:**
```zig
//! This is the [module_name] module for the bls12-381 signature library
//! Copyright (c) 2025 zk-evm
//! SPDX-License-Identifier: Apache-2.0
//!
//! [Brief description of what this module does]

const std = @import("std");
// ... other imports in alphabetical order
```

### Module-Level Documentation

**Every module MUST have:**
- **Purpose statement** (one clear sentence)
- **Key responsibilities** (bullet points)
- **Thread safety guarantees** (if applicable)
- **Memory management contract** (who owns what)
- **Error handling strategy**

**Example:**
```zig
//! Signature aggregation operations for BLS12-381 cryptographic signatures.
//! Provides thread-safe batch operations with configurable memory pooling.
//! 
//! Key responsibilities:
//! - Aggregate multiple signatures into a single signature
//! - Batch verification of aggregated signatures  
//! - Memory pool management for scratch buffers
//! - Thread-safe concurrent aggregation operations
//!
//! Thread safety: All public functions are thread-safe
//! Memory management: Caller owns all input/output memory
//! Error handling: All operations return detailed BLST_ERROR codes
```

### Function Documentation Standards

**Every public function MUST have:**
```zig
/// Brief description of what the function does.
/// 
/// This function performs [specific operation] by [method]. It ensures
/// [guarantees] and will fail if [conditions].
///
/// # Parameters
/// - `param1`: Description and ownership semantics
/// - `param2`: Valid ranges and constraints
/// 
/// # Returns
/// - `Success`: What success means and what you get
/// - `Error.Specific`: When and why this error occurs
///
/// # Safety
/// - Memory safety guarantees
/// - Thread safety behavior
/// - Cryptographic security properties
///
/// # Performance
/// - Time complexity
/// - Memory usage
/// - Any performance notes
pub fn criticalFunction(param1: Type1, param2: Type2) !ReturnType {
```

**NO EXAMPLES IN FUNCTION DOCS** - Examples belong in tests and module docs only.

### Variable and Type Naming

**Strictly enforced conventions:**
```zig
// Types: PascalCase
const PublicKey = struct { ... };
const SignatureError = error { ... };

// Variables: camelCase  
const secretKey = generateKey();
var signatureBuffer: [96]u8 = undefined;

// Constants: snake_case or SCREAMING_SNAKE_CASE
const max_signature_size = 96;
const DEFAULT_THREAD_COUNT = 8;

// Functions: camelCase
pub fn aggregateSignatures() void { ... }
pub fn verifyBatch() !bool { ... }
```

### Code Formatting (Zero Tolerance)

**Use `zig fmt` religiously.** Additionally:

```zig
// Function parameters: one per line if > 3 params
pub fn complexFunction(
    param1: Type1,
    param2: Type2, 
    param3: Type3,
    param4: Type4,
) !ReturnType {
    // Implementation
}

// Error handling: explicit and verbose
const result = operation() catch |err| switch (err) {
    error.OutOfMemory => return error.InsufficientResources,
    error.InvalidInput => return error.MalformedData,
    else => return err,
};

// No single-letter variables except for well-known iterators
for (signatures, 0..) |sig, i| { // 'i' is acceptable
    // 'sig' is descriptive enough in this context
}

// Imports: grouped and alphabetized
const std = @import("std");
const testing = std.testing;

const c = @import("c_imports.zig").c;
const util = @import("util.zig");
```

### Memory Management (Critical)

**Every allocation MUST have:**
```zig
// 1. Clear ownership documentation
/// Caller owns returned memory and must call deinit()
pub fn createBuffer() ![]u8 { ... }

// 2. Explicit cleanup paths
var buffer = try createBuffer();
defer buffer.deinit(); // ALWAYS pair allocations

// 3. Error handling that doesn't leak
const result = tryOperation() catch |err| {
    cleanup(); // Clean up before propagating
    return err;
};
```

### Error Handling (Mandatory Excellence)

```zig
// Detailed error types
const SignatureError = error{
    /// Input signature bytes are malformed or wrong length
    MalformedSignature,
    /// Public key failed group membership check
    InvalidPublicKey,
    /// Pairing verification failed - signature is invalid
    VerificationFailed,
    /// Insufficient memory for scratch buffers
    InsufficientMemory,
};

// Comprehensive error propagation
pub fn verifySignature(sig: []const u8, pk: []const u8, msg: []const u8) SignatureError!bool {
    const parsed_sig = parseSignature(sig) catch |err| switch (err) {
        error.InvalidLength => return error.MalformedSignature,
        error.InvalidEncoding => return error.MalformedSignature,
        else => return err,
    };
    // ... continue with proper error handling
}
```

## 📁 File Organization

### Directory Structure (Enforced)

```
src/
├── main.zig               # Entry point only
├── c_imports.zig          # Centralized C imports (REQUIRED)
├── root.zig               # Main library interface
├── root_min_pk.zig        # Min-PK variant exports  
├── root_min_sig.zig       # Min-Sig variant exports
├── root_c_abi_min_pk.zig  # C ABI for Min-PK
├── root_c_abi_min_sig.zig # C ABI for Min-Sig
├── sig_variant.zig        # Core signature operations
├── pairing.zig            # Pairing operations
├── memory_pool.zig        # Memory management
├── thread_pool.zig        # Threading utilities
├── multi_point.zig        # Multi-point operations
├── util.zig               # Utility functions
└── benchmarks.zig         # Performance benchmarks
```

### Import Organization (Strict Order)

```zig
// 1. Standard library imports (alphabetical)
const std = @import("std");
const testing = std.testing;

// 2. Builtin imports
const builtin = @import("builtin");

// 3. Local imports (dependency order, then alphabetical)
const c = @import("c_imports.zig").c;
const util = @import("util.zig");
const pairing = @import("pairing.zig");

// 4. External dependencies (if any)
// const external = @import("external_lib");
```

## 📚 Documentation Requirements

### Module Documentation (Mandatory)

**Every module needs comprehensive documentation:**

```zig
//! # Module Name
//!
//! Brief description of the module's purpose and functionality.
//!
//! ## Key Features
//! - Feature 1: Description and benefits
//! - Feature 2: Description and benefits  
//! - Feature 3: Description and benefits
//!
//! ## Usage Example
//! ```zig
//! const result = try module.primaryFunction(params);
//! defer result.deinit();
//! ```
//!
//! ## Thread Safety
//! All functions in this module are thread-safe unless explicitly noted.
//!
//! ## Memory Management  
//! Caller is responsible for all memory management unless otherwise specified.
//!
//! ## Error Handling
//! All functions return detailed error codes. See individual function docs.
```

### Function Documentation (Comprehensive)

**Required sections for ALL public functions:**

1. **Purpose** - What it does (one sentence)
2. **Parameters** - Every parameter with constraints
3. **Returns** - Every possible return value
4. **Errors** - Every possible error condition
5. **Safety** - Memory and thread safety guarantees
6. **Performance** - Big O complexity if relevant
7. **Cryptographic Properties** - Security guarantees

### Code Comments (Strategic)

```zig
// Good: Explains WHY, not WHAT
// Use batch verification for performance - 100x faster than individual
const result = try batchVerify(signatures);

// Bad: States the obvious  
// Create a new signature
const sig = try createSignature();

// Good: Explains complex algorithms
// Pippenger's algorithm for multi-scalar multiplication
// Reduces complexity from O(n²) to O(n log n) for large n
const result = pippengerMultiScalar(points, scalars);

// Good: Security-critical notes
// SECURITY: This buffer contains secret key material - clear on scope exit
defer std.crypto.utils.secureZero(u8, key_buffer);
```

## ✅ Testing Requirements

### Test Coverage (100% for New Code)

**Every contribution MUST include:**

```zig
test "descriptive_test_name_explaining_what_is_tested" {
    // 1. Setup (Given)
    const allocator = std.testing.allocator;
    var context = try TestContext.init(allocator);
    defer context.deinit();
    
    // 2. Action (When)  
    const result = try context.performOperation(valid_input);
    
    // 3. Verification (Then)
    try std.testing.expect(result.isValid());
    try std.testing.expectEqual(expected_value, result.getValue());
}

test "error_condition_descriptive_name" {
    // Test EVERY error condition
    try std.testing.expectError(error.ExpectedError, failingFunction());
}

test "edge_case_descriptive_name" {
    // Test edge cases: empty inputs, boundary values, etc.
}

test "memory_safety_descriptive_name" {
    // Test with testing allocator to catch leaks
}
```

### Performance Regression Tests

**New features MUST include benchmark tests:**

```zig
test "benchmark_new_feature" {
    const iterations = 1000;
    const timer = Timer.start();
    
    for (0..iterations) |_| {
        _ = try newFeature(test_input);
    }
    
    const elapsed = timer.elapsed();
    const ops_per_sec = @as(f64, iterations) / (elapsed / 1000.0);
    
    // Performance regression check
    try std.testing.expect(ops_per_sec > MINIMUM_EXPECTED_THROUGHPUT);
    
    std.debug.print("New feature: {d:.0} ops/sec\n", .{ops_per_sec});
}
```

## ⚡ Performance Requirements

### Benchmarking (Mandatory)

**All performance-critical code MUST:**
- Include benchmark tests in `/src/benchmarks.zig`
- Demonstrate no regression vs existing implementation
- Include complexity analysis in documentation
- Provide memory usage analysis

### Optimization Standards

```zig
// Good: Clear performance intent
pub fn criticalPath(data: []const u8) !Result {
    // Hot path optimization: avoid allocations
    var stack_buffer: [256]u8 = undefined;
    
    // Use stack allocation when size is bounded
    if (data.len <= stack_buffer.len) {
        return processOnStack(data, &stack_buffer);
    }
    
    // Fallback to heap only when necessary
    return processOnHeap(data);
}

// Bad: Unnecessary allocations in hot path
pub fn inefficientPath(data: []const u8) !Result {
    const buffer = try allocator.alloc(u8, data.len); // Avoid in hot paths
    defer allocator.free(buffer);
    // ...
}
```

## 📝 Commit Standards

### Commit Message Format (Strictly Enforced)

```
type(scope): brief description in present tense

Detailed explanation of what and why, not how.

Addresses: #issue_number
Co-authored-by: Name <email> (if applicable)
```

**Valid Types:** `feat`, `fix`, `docs`, `perf`, `refactor`, `test`, `ci`, `security`

**Valid Scopes:** `crypto`, `memory`, `thread`, `api`, `build`, `bench`, `test`

**Examples:**
```
feat(crypto): add batch signature verification with memory pooling

Implements efficient batch verification using Pippenger's algorithm
for multi-scalar multiplication. Reduces verification time from O(n²) 
to O(n log n) for large signature sets.

Performance: 66,030 sigs/sec in batch mode vs 660 sigs/sec individual.
Memory usage: Fixed 3KB context + configurable scratch buffers.

Addresses: #123
```

```
fix(memory): resolve buffer overflow in signature serialization

The signature compression function was not properly validating output
buffer size, leading to potential buffer overflow with malformed inputs.

Added explicit size checks and comprehensive error handling.
All existing tests pass, added 3 new edge case tests.

Addresses: #456
```

### What Makes a Commit Acceptable

**✅ Good Commits:**
- **Atomic**: One logical change per commit
- **Complete**: Includes tests, docs, benchmarks if needed
- **Tested**: All tests pass, no regressions
- **Documented**: Clear commit message and code comments
- **Formatted**: Perfect `zig fmt` compliance

**❌ Rejected Commits:**
- Multiple unrelated changes in one commit
- Incomplete test coverage
- Missing or poor documentation
- Performance regressions
- Style violations (even minor ones)
- Debug print statements left in code
- TODO comments without associated issues

## 🔍 Pull Request Process

### Before Submitting

**Self-Review Checklist (MANDATORY):**

```bash
# 1. Code Quality
zig fmt src/                         # Format all code
zig build                            # Build succeeds
zig build test                       # All tests pass
zig build bench                      # No performance regression

# 2. Documentation
# - All functions documented
# - Module-level docs updated
# - README updated if needed
# - CHANGELOG.md entry added

# 3. Git Hygiene  
git log --oneline -10                # Clean commit history
git diff --check                     # No whitespace errors
```

### PR Description Template

```markdown
## Summary
Brief description of changes and motivation.

## Changes Made
- [ ] Added feature X with Y performance characteristics
- [ ] Updated documentation for Z
- [ ] Added N comprehensive tests
- [ ] Included benchmark results showing P improvement

## Testing
- [ ] Unit tests added/updated (coverage: X%)
- [ ] Integration tests pass
- [ ] Performance benchmarks included
- [ ] Memory leak tests pass (valgrind clean)
- [ ] Cross-platform testing completed

## Performance Impact
| Operation | Before | After | Change |
|-----------|--------|-------|---------|
| Operation X | N ops/sec | M ops/sec | +X% |

## Security Review
- [ ] No new attack vectors introduced
- [ ] Input validation comprehensive
- [ ] Memory safety verified
- [ ] Cryptographic correctness validated

## Documentation
- [ ] Module docs updated
- [ ] Function docs complete
- [ ] README updated (if needed)
- [ ] Examples provided (if needed)

## Breaking Changes
None / List any breaking changes

## Related Issues
Closes #123, Addresses #456
```

## 🎯 Review Criteria

### Automatic Rejection Criteria

**PRs will be closed immediately for:**

1. **Formatting Violations**
   - Any `zig fmt` discrepancies
   - Inconsistent spacing or indentation
   - Wrong import ordering
   - Missing module headers

2. **Documentation Failures**
   - Missing function documentation
   - Unclear parameter descriptions
   - No error condition documentation
   - Missing safety guarantees

3. **Code Quality Issues**
   - Magic numbers without constants
   - Unclear variable names
   - Nested callbacks or complex control flow
   - Unnecessary complexity

4. **Testing Deficiencies**
   - Missing test coverage
   - Tests that don't actually test the functionality
   - No error condition testing
   - Performance regression

5. **Memory Safety Violations**
   - Potential memory leaks
   - Buffer overruns possible
   - Uninitialized memory access
   - Improper error cleanup

### Detailed Review Process

**Phase 1: Automated Checks**
- ✅ Build success
- ✅ All tests pass  
- ✅ No performance regression
- ✅ Code formatting compliance
- ✅ Documentation completeness

**Phase 2: Code Review**
- 🔍 Architecture and design patterns
- 🔍 Memory safety and resource management  
- 🔍 Error handling completeness
- 🔍 Thread safety analysis
- 🔍 Performance characteristics

**Phase 3: Cryptographic Review**
- 🔒 Security properties maintained
- 🔒 No timing attack vulnerabilities
- 🔒 Proper input validation
- 🔒 Cryptographic correctness

**Phase 4: Integration Testing**
- 🧪 Cross-platform compatibility
- 🧪 C ABI compatibility maintained
- 🧪 No breaking changes to public API
- 🧪 Performance benchmarks updated

## 🚫 Rejected Contribution Examples

**Real examples of what gets rejected:**

### Bad Module Comment
```zig
//! crypto stuff
//! does crypto things

// REJECTED: Completely useless documentation
```

### Good Module Comment  
```zig
//! BLS12-381 signature verification and aggregation operations.
//!
//! Provides thread-safe cryptographic operations for BLS signatures over the 
//! BLS12-381 elliptic curve. Implements both individual and batch verification
//! modes with configurable memory pooling for high-throughput scenarios.
//!
//! This module is the core of the signature verification system, handling:
//! - Single signature verification with domain separation
//! - Batch aggregate signature verification (up to 100x performance gain)
//! - Memory pool management for scratch buffers
//! - Thread-safe concurrent operations
//!
//! Thread safety: All public functions are thread-safe
//! Memory management: Caller owns all input/output, library manages scratch buffers
//! Error handling: Returns detailed BLST_ERROR codes for all failure modes
```

### Bad Function Documentation
```zig
/// signs stuff
pub fn sign(msg: []const u8) !Signature {

// REJECTED: Useless documentation, unclear parameters, no error info
```

### Good Function Documentation
```zig
/// Creates a BLS signature over the provided message using this secret key.
///
/// Implements the BLS signature scheme as specified in the IETF draft with
/// domain separation for security. The signature can be verified using the
/// corresponding public key and will be deterministic for the same inputs.
///
/// # Parameters
/// - `message`: Arbitrary byte message to sign (any length supported)
/// - `dst`: Domain separation tag as per IETF spec (must be non-empty)
/// - `aug`: Optional augmentation data for advanced use cases (can be null)
///
/// # Returns
/// - `Signature`: Valid BLS signature that can be verified with corresponding public key
///
/// # Errors
/// - `error.InvalidDST`: Domain separation tag is empty or malformed
/// - `error.OutOfMemory`: Insufficient memory for signature computation
/// - `error.InvalidMessage`: Message validation failed (implementation-specific)
///
/// # Safety
/// - Memory safe: All inputs validated, no buffer overruns possible
/// - Thread safe: Can be called concurrently from multiple threads
/// - Cryptographically secure: Uses constant-time operations where applicable
///
/// # Performance
/// - Time complexity: O(1) - constant time regardless of message size
/// - Memory usage: ~2KB stack allocation for computation context
/// - Typical latency: ~442μs on x86_64 with ADX support
pub fn sign(self: *const SecretKey, message: []const u8, dst: []const u8, aug: ?[]const u8) !Signature {
```

### Bad Error Handling
```zig
pub fn operation() !void {
    doSomething() catch {};  // REJECTED: Silently swallowing errors
    
    const result = try anotherThing();
    // REJECTED: No validation of result
}
```

### Good Error Handling
```zig
pub fn operation() !void {
    doSomething() catch |err| switch (err) {
        error.ExpectedError => return error.OperationFailed,
        error.MemoryError => return error.InsufficientResources,
        else => {
            std.log.err("Unexpected error in operation: {}", .{err});
            return err;
        }
    };
    
    const result = try anotherThing();
    if (!result.isValid()) {
        return error.InvalidResult;
    }
}
```

## 🚀 Getting Started

### Your First Contribution

1. **Fork the repository**
2. **Read this document completely** (yes, every word)
3. **Set up development environment** exactly as specified
4. **Pick a small, well-defined issue** to start with
5. **Follow the standards religiously**
6. **Test extensively** before submitting

### Issue Selection

**Good First Issues:**
- Documentation improvements (with substantial value)
- Additional test cases for edge conditions
- Performance optimizations with measurable impact
- Build system improvements

**Avoid These:**
- Large architectural changes (discuss first in issues)
- Breaking API changes (requires extensive discussion)
- Adding new cryptographic algorithms (major review required)

## 🎓 Resources for Contributors

- [Zig Language Reference](https://ziglang.org/documentation/master/)
- [BLS12-381 Mathematical Background](https://hackmd.io/@benjaminion/bls12-381)
- [Cryptographic Engineering Best Practices](https://www.cryptoengineering.org/)
- [Memory Safety in Systems Programming](https://github.com/rust-lang/rfcs/blob/master/text/2085-platform-intrinsics.md)

## 🤝 Community

- **Be respectful** - Everyone is learning
- **Be precise** - Vague questions get vague answers
- **Be patient** - Quality review takes time
- **Be prepared** - Read docs before asking questions

## ⚖️ License

By contributing to this project, you agree that your contributions will be licensed under the Apache License 2.0, and you certify that you have the right to make such contributions.

---

<div align="center">

**Quality is not negotiable. Standards are not suggestions.**

*If these requirements seem excessive, this project might not be the right fit for your contribution style.*

</div>
