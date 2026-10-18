---
name: review-cpp-simd
description: Review C++ hot loops and kernels for auto-vectorization and portable SIMD readiness, including Google Highway suitability. Use when vectorization fails, SIMD throughput is unexpectedly low, scalar cleanup is needed, data layout blocks vector access, or code needs review for dependencies, aliasing, branches, gathers, alignment, reductions, and tail handling.
---

# Review C++ SIMD

Review the kernel for profitable, correct vectorization. Prefer portable, teachable structure
and measured results over architecture-specific cleverness.

## Workflow

1. Establish semantics, element types, trip counts, alignment, aliasing, target CPUs, and
   numerical requirements.
2. Identify loop-carried dependencies, reductions, calls, branches, pointer aliasing, mixed
   widths, irregular access, and early exits.
3. Inspect the data layout and distinguish contiguous loads from stride, gather, scatter, and
   pointer-chasing patterns.
4. Check the compiler's vectorization report and generated assembly when available.
5. Decide among:
   - keep scalar
   - restructure for auto-vectorization
   - use standard or compiler-assisted vectorization
   - use Google Highway for portable explicit SIMD
   - use target-specific intrinsics only when the target contract justifies them
6. Design main-vector and tail paths, including small-input behavior.
7. Benchmark against a correct scalar reference across representative sizes.

Read [references/simd-review-guide.md](references/simd-review-guide.md) before recommending
loop or layout changes.

## Correctness Guardrails

- Do not assume alignment, non-aliasing, or padding unless the API guarantees it.
- Preserve integer overflow and floating-point semantics; call out any relaxed math.
- Handle zero-length, shorter-than-one-vector, and non-multiple lengths.
- Avoid out-of-bounds masked loads unless the SIMD API explicitly guarantees safety.
- Keep a scalar oracle and test randomized plus boundary inputs.
- Do not infer emitted instructions solely from a ternary expression or branchless source.

## Output

Report:

1. SIMD suitability and likely payoff
2. blockers with exact source locations
3. recommended restructuring in priority order
4. auto-vectorization versus Google Highway decision
5. tail, alignment, aliasing, and numerical risks
6. verification commands and benchmark plan
