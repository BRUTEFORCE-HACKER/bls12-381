## 🎯 Pull Request Summary

**Type**: [feat|fix|docs|perf|refactor|test|ci|security]  
**Component**: [crypto|memory|thread|api|build|bench|test]

<!-- 
BEFORE SUBMITTING: Run the self-review checklist in CONTRIBUTING.md
PRs that don't meet standards will be closed immediately.
-->

### Brief Description
<!-- One clear sentence describing what this PR does -->

### Related Issues
<!-- Required: Link to issues this PR addresses -->
- Closes #XXX
- Addresses #YYY
- Related to #ZZZ

---

## 📋 Changes Made

### Code Changes
- [ ] **Core functionality**: [Description of main changes]
- [ ] **API updates**: [New/changed public interfaces]  
- [ ] **Performance**: [Optimizations or impacts]
- [ ] **Documentation**: [Updated docs and comments]

### Files Modified
<!-- List all files with brief description of changes -->
- `src/module.zig`: [Description]
- `build.zig`: [Description]
- `README.md`: [Description]

---

## ✅ Quality Checklist

### Code Quality
- [ ] **Code formatted**: `zig fmt` applied to all files
- [ ] **Builds successfully**: `zig build` passes
- [ ] **All tests pass**: `zig build test` succeeds
- [ ] **No regressions**: Existing functionality unaffected
- [ ] **Error handling**: All error paths properly handled
- [ ] **Memory safety**: No leaks or unsafe operations

### Documentation
- [ ] **Module docs**: Updated for any new modules
- [ ] **Function docs**: All public functions documented per standards
- [ ] **Code comments**: Strategic comments explaining complex logic
- [ ] **README updates**: Updated if public API changed
- [ ] **CHANGELOG**: Entry added for user-facing changes

### Testing
- [ ] **New tests added**: For all new functionality
- [ ] **Edge cases covered**: Boundary conditions tested
- [ ] **Error conditions**: All error paths tested
- [ ] **Memory leak tests**: Clean with testing allocator
- [ ] **Performance tests**: Benchmarks added if applicable

### Performance (if applicable)
- [ ] **No regression**: Performance maintained or improved
- [ ] **Benchmarks included**: Measurements provided below
- [ ] **Complexity analysis**: Big O characteristics documented
- [ ] **Memory usage**: Impact analyzed and documented

---

## 📊 Performance Impact

<!-- Required for any code changes affecting critical paths -->

| Operation | Before | After | Change | Notes |
|-----------|--------|-------|---------|-------|
| Operation Name | X ops/sec | Y ops/sec | +Z% | Measurement method |
| Memory Usage | A KB | B KB | ±C KB | Peak/average |

**Benchmark Command Used**: `zig build bench -Doptimize=ReleaseFast`

**Test Environment**:
- Platform: [OS and architecture]
- CPU: [Processor model] 
- Compiler: Zig [version]
- Build flags: [optimization level, etc.]

---

## 🔒 Security Considerations

### Cryptographic Changes
- [ ] **No security regressions**: Existing security properties maintained
- [ ] **Input validation**: All new inputs properly validated  
- [ ] **Timing safety**: No new timing attack vectors introduced
- [ ] **Memory safety**: Sensitive data properly cleared

### Code Review Focus
<!-- Highlight areas that need special security attention -->
- **Critical sections**: [List any security-sensitive code]
- **New attack surfaces**: [Any new input/output paths]
- **Cryptographic correctness**: [Changes to crypto operations]

---

## 🧪 Testing Strategy

### Test Coverage
```
Current Coverage: X%
New Coverage: Y%
```

### Test Categories Added
- [ ] **Unit tests**: [Number] new tests for core functionality
- [ ] **Integration tests**: [Number] tests for component interaction
- [ ] **Error condition tests**: [Number] tests for failure modes
- [ ] **Performance tests**: [Number] benchmark tests added
- [ ] **Memory safety tests**: Valgrind/leak detection tests

### Test Execution
```bash
# Commands used to verify this PR:
zig build test                    # Result: PASS
zig build bench                   # Result: [performance data]
zig build -Doptimize=ReleaseFast  # Result: PASS
```

---

## 💔 Breaking Changes

<!-- If any breaking changes -->
- [ ] **No breaking changes** 
- [ ] **Breaking changes present** (details below)

### Breaking Change Details
<!-- Required if breaking changes present -->
- **What breaks**: [Specific APIs or behaviors that change]
- **Migration path**: [How users can update their code]
- **Deprecation timeline**: [When old APIs will be removed]
- **Impact assessment**: [How many users affected]

---

## 📖 Documentation Updates

### Updated Documentation
- [ ] **Function docstrings**: All new/changed functions documented
- [ ] **Module documentation**: Updated for architectural changes
- [ ] **API examples**: Usage examples provided for new features
- [ ] **Performance docs**: Benchmark results documented

### Documentation Quality
- [ ] **Clarity**: Documentation is clear and unambiguous
- [ ] **Completeness**: All parameters, returns, errors documented
- [ ] **Accuracy**: Documentation matches actual behavior
- [ ] **Examples**: Practical examples provided where helpful

---

## 🔄 Review Readiness

### Self-Review Completed
- [ ] **Code review**: I have reviewed my own code thoroughly
- [ ] **Testing**: I have tested all changes extensively
- [ ] **Documentation**: I have verified all documentation is accurate
- [ ] **Standards**: I have followed all coding standards precisely

### Review Notes for Maintainers
<!-- Anything specific you want reviewers to focus on -->
- **Focus areas**: [What should reviewers pay special attention to?]
- **Concerns**: [Any areas you're unsure about?]
- **Trade-offs**: [Any compromises made and why?]

---

## 📝 Additional Notes

<!-- Any other relevant information -->
- **Implementation notes**: [Technical details or decisions]
- **Future work**: [Related improvements that could follow]
- **Dependencies**: [Any new dependencies or version requirements]

---

## ✋ Reviewer Checklist

<!-- For maintainers - DO NOT FILL OUT -->
<details>
<summary>Maintainer Review Checklist (for reviewers only)</summary>

### Code Quality Review
- [ ] Follows established patterns and conventions
- [ ] No code smells or anti-patterns
- [ ] Appropriate error handling throughout
- [ ] Memory management is correct and safe
- [ ] Thread safety considerations addressed

### Cryptographic Review  
- [ ] Cryptographic operations are correct
- [ ] No timing attack vectors introduced
- [ ] Input validation is comprehensive
- [ ] Security properties maintained

### Performance Review
- [ ] No performance regressions in critical paths
- [ ] New optimizations are measurable and documented
- [ ] Memory usage is reasonable
- [ ] Scaling characteristics are acceptable

### Documentation Review
- [ ] Documentation meets quality standards
- [ ] All public APIs are documented
- [ ] Examples are correct and helpful
- [ ] Breaking changes are clearly documented

</details>
