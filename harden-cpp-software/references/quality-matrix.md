# C++ Quality Matrix

## Tool Selection

| Risk | Primary tool | Complement |
|---|---|---|
| Compiler and portability defects | Strict GCC/Clang/MSVC warnings | Multiple compiler jobs |
| Style drift | `clang-format` check | Repository hooks |
| Semantic/API misuse | `clang-tidy` | Project-specific checks |
| Broad static defects | Cppcheck or another independent analyzer | Compiler analysis |
| Memory errors | AddressSanitizer | Focused Valgrind memcheck |
| Undefined behavior | UBSan | Strict non-recovering job |
| Data races | ThreadSanitizer | Deterministic concurrency tests |
| Leaks and lifetime | ASan leak detection or Valgrind | Teardown stress |
| Parser/input defects | Coverage-guided fuzzing with sanitizers | Seed regression tests |
| Performance regression | Benchmarks and profilers | Statistical comparison |

## Compatibility Rules

- ASan plus UBSan is commonly useful when the compiler/runtime supports the combination.
- TSan must use its own build and test job.
- Valgrind should use a plain debug build without ASan or TSan.
- Profiling builds should preserve representative optimization and avoid instrumentation that changes the investigated behavior.
- Static analyzers need compile commands matching the intended configuration.
- Fuzzers need deterministic reproducers and should not depend on unavailable production services.

## CI Layering

1. Fast gate: formatting check, primary compiler, strict warnings, focused unit tests.
2. Analysis gate: static analyzers and an alternate compiler or platform.
3. Dynamic gate: separate ASan/UBSan and TSan jobs.
4. Scheduled or release gate: Valgrind, fuzzing, full integration matrix, and longer benchmarks.

Adjust cadence to runtime and risk. Do not remove an expensive gate merely because it is too slow for every pull request; schedule it and keep failures visible.

## Suppression Policy

Every suppression must identify the tool, diagnostic, affected code or dependency, justification, owner, and removal condition. Scope suppressions to the smallest target, file, line, or external library boundary possible.

## Acceptance Checklist

- Each required job is reproducible from a clean build directory.
- Tool failures produce source locations or retained artifacts.
- Expected failures and unsupported platforms are explicit.
- Third-party findings are separated from project findings.
- CI and local documentation use the same options and target names.
