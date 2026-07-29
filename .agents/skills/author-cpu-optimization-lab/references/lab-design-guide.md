# CPU Optimization Lab Design Guide

## Contents

- Recommended structure
- Experiment design
- Build matrix
- Profiling
- Branch-prediction example
- Review checklist

## Recommended structure

Adapt to local conventions:

```text
src/<topic>/<project>/
├── CMakeLists.txt
├── README.md
├── common.h
├── benchmark_harness.h
├── benchmark_harness.cpp
├── baseline.cpp
├── baseline.h
├── optimized.cpp
├── optimized.h
├── main.cpp
├── main_baseline.cpp
└── main_optimized.cpp
```

Use one comparison runner and standalone binaries for profiler isolation. For a smaller lab,
collapse files while preserving a clear correctness oracle and separate timed kernels.

## Experiment design

- Teach one principal effect.
- Keep input data, useful work, output, and timing harness identical across variants.
- Generate inputs with a fixed seed outside timed regions.
- Warm up when appropriate and explain whether caches are warm or cold.
- Run enough iterations to reduce timer noise.
- Report multiple samples and a robust summary such as median.
- Validate outputs before measuring.
- Make preprocessing visible and state whether results are steady-state or end-to-end.
- Avoid undefined behavior, data races, and reliance on accidental compiler behavior.

Include constraints that prevent bypassing the lesson, such as no explicit SIMD in a branch lab
or no layout change in a pure loop-order lab.

## Build matrix

Optimization levels can reveal different lessons:

| Variant | Typical purpose |
|---|---|
| `-O0 -g` | source-level teaching baseline only |
| `-O2 -g` | common optimized compiler behavior |
| `-O3 -g` | aggressive optimization and vectorization |

Add ISA flags only when the lab documents hardware requirements or runtime dispatch. Avoid making
`-mavx2` an unspoken default.

Example CMake targets:

```text
bench_all_O0, bench_all_O2, bench_all_O3
bench_baseline_O0, bench_baseline_O2, bench_baseline_O3
bench_optimized_O0, bench_optimized_O2, bench_optimized_O3
```

## Profiling

Start with elapsed time and a focused set of counters:

```bash
perf stat -r 5 -e cycles,instructions,branches,branch-misses -- ./bench
perf record -g -- ./bench
perf report
```

Add cache, TLB, frontend, or vector metrics only when they test the lesson's hypothesis. Note that
events vary by CPU and may require permissions.

Document:

- platform and CPU
- compiler and version
- build flags
- input size and repeat count
- whether preprocessing is included
- exact command

## Branch-prediction example

A useful exercise repeats a threshold query over deterministic random integers:

- baseline: branch over random-order input
- ordering variant: partition or sort once, then repeat the scan
- branchless variant: compute a selected value without data-dependent control flow
- idiomatic variant: use a conditional expression and inspect compiler output

The oracle must preserve all original values and produce the same total. The lesson is not
"sorting is always faster": preprocessing only wins when repeated work amortizes its cost, and
ordering may not be semantically legal.

Useful metrics:

```text
IPC = instructions / cycles
branch MPKI = branch-misses * 1000 / instructions
```

Expected results should remain qualitative because compiler, optimization level, ISA, and CPU
predictor differ.

## Review checklist

- [ ] One explicit learning goal and hypothesis
- [ ] Deterministic fixed input
- [ ] Correct scalar oracle
- [ ] Identical useful work across variants
- [ ] No setup or I/O in timed region
- [ ] Dead-code elimination prevented
- [ ] Edge cases and randomized correctness tested
- [ ] Standalone profiler targets
- [ ] Portable baseline
- [ ] Hardware-specific flags documented
- [ ] Before/after metrics tied to the concept
- [ ] No fabricated timings
- [ ] Root catalog and agent instructions updated
