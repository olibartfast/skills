---
name: harden-cpp-software
description: Build and apply proportional compile-time and verification quality gates for C++17/20/23 software using warnings, formatting, static analysis, sanitizers, Valgrind, fuzzing, and CI matrices. Use when establishing code-quality policy, diagnosing undefined behavior or data races, selecting compatible dynamic-analysis tools, enabling warnings-as-errors, preparing a release, or reviewing whether a C++ project has enough automated defect detection.
---

# Harden C++ Software

Choose the smallest complementary quality matrix that addresses the project's actual risks. Keep correctness tools isolated when their runtimes or instrumentation conflict.

## Workflow

1. Inspect compilers, standard library, platforms, build types, test targets, CI limits, third-party warning boundaries, and existing suppressions.
2. Classify risks: compile-time defects, API misuse, undefined behavior, memory safety, races, leaks, malformed input, portability, and release regressions.
3. Read [references/quality-matrix.md](references/quality-matrix.md).
4. Select independent build directories and jobs for incompatible configurations.
5. Introduce strict warnings and analysis incrementally, keeping third-party diagnostics separate.
6. Run tools against representative tests or workloads and retain actionable reports.
7. Minimize suppressions and document the exact false positive or external defect.
8. Make required gates reproducible locally before enforcing them in CI.

## Quality Rules

- Treat warnings as errors in controlled project targets, not blindly in third-party code.
- Keep formatting checks non-mutating in CI.
- Generate an accurate compilation database before compiler-aware static analysis.
- Do not combine AddressSanitizer and ThreadSanitizer in one binary.
- Keep Valgrind runs free of ASan and TSan instrumentation.
- Use UBSan recovery policy deliberately; strict jobs should fail on the first finding.
- Run fuzz targets with sanitizers, bounded resources, persisted reproducers, and a maintained seed corpus.
- Prefer fixing root causes over growing suppression files.
- Pin or record tool versions when diagnostics are release gates.
- Never interpret a clean single tool run as proof that the software is defect-free.

## Deliverable

Provide the risk-to-tool matrix, build and CI jobs, incompatibilities, commands, suppression policy, findings and fixes, runtime cost, and remaining coverage gaps.
