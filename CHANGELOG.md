# Changelog

All notable changes to the BLS12-381 signature library will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-09-21

### Features
- Initial BLS12-381 signature implementation
- Min-PK and Min-Sig variants support
- Thread-safe memory pooling system
- C ABI bindings for cross-language compatibility
- Comprehensive test suite with cryptographic validation
- Multi-threaded signature aggregation
- BLST library integration with ADX optimizations
- Cross-platform support (Linux, macOS, Windows)

### Security Features
- Memory-safe implementation in Zig
- Constant-time operations where applicable
- Input validation for all cryptographic operations
- Protection against timing attacks in critical paths
- Secure memory clearing for sensitive data

### Performance Benchmarks
- Key Generation: 1,265,227 ops/sec (0.8 μs latency)
- Signing: 2,261 ops/sec (442.3 μs latency)  
- Verification: 660 ops/sec (1,516.1 μs latency)
- Signature Aggregation: 68,836 ops/sec (14.5 μs latency)
- Aggregate Verification: 66,030 effective sigs/sec in batch mode

---

## Release Guidelines

### Version Numbering
- **MAJOR**: Breaking changes to public API
- **MINOR**: New features, performance improvements
- **PATCH**: Bug fixes, documentation updates

### Release Criteria
- ✅ All tests pass on all supported platforms
- ✅ Performance benchmarks show no regression
- ✅ Documentation updated and complete
- ✅ Security review completed for crypto changes
- ✅ Memory safety verified (no leaks detected)
- ✅ C ABI compatibility maintained
- ✅ Cross-platform compatibility confirmed

### Performance Regression Policy
Any change that reduces performance by >5% in critical operations will be rejected unless:
- Provides significant security benefits
- Enables important new functionality  
- Has explicit approval from maintainers

---

## Breaking Change Policy

This library follows semantic versioning strictly:
- **Pre-1.0**: Breaking changes allowed in minor versions (with clear migration guide)
- **Post-1.0**: Breaking changes only in major versions
- All breaking changes require RFC process and community discussion

## Security Disclosure

See [SECURITY.md](SECURITY.md) for our security policy and responsible disclosure process.
