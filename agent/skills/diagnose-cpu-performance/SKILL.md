---
description: "Diagnose C and C++ CPU performance problems from source, benchmark results, compiler output, and hardware counters. Use when a hot loop, benchmark regression, low IPC, branch misses, cache misses, frontend stalls, memory latency, TLB pressure, or unclear CPU bottleneck needs measurement-driven classification before optimization."
---
# Diagnose CPU Performance

Classify the dominant bottleneck before proposing code changes. Preserve correctness and
benchmark validity ahead of speed.

## Workflow

1. Establish the workload, target machine, compiler, flags, input, and success metric.
2. Verify that the benchmark is deterministic, long enough to measure, and protected from
   dead-code elimination.
3. Reproduce the baseline when execution is authorized and practical. Record repeated runs,
   not a single timing.
4. Inspect the hot code and compiler output without assuming that source-level constructs map
   directly to machine instructions.
5. Collect the smallest counter set that can distinguish plausible bottlenecks.
6. Classify the issue as one or more of:
   - frontend or instruction delivery
   - branch prediction
   - cache locality
   - memory latency or insufficient memory-level parallelism
   - TLB or address translation
   - IPC, ILP, dependency chains, or reorder-buffer pressure
   - compute throughput or SIMD underutilization
7. Propose one controlled experiment or minimal change that tests the hypothesis.
8. Re-measure correctness, wall time, and the counters that motivated the change.

Read [references/bottleneck-guide.md](references/bottleneck-guide.md) before interpreting
counters or recommending an optimization.

## Measurement Rules

- Compare identical inputs, affinity, compiler flags, and runtime conditions.
- Report CPU model and tool availability when results depend on hardware.
- Treat `perf` events as evidence, not universal thresholds; event names and availability vary.
- Separate preprocessing cost from steady-state cost. Amortize preprocessing only when the
  workload repeats enough to justify it.
- Check optimized assembly or vectorization reports before claiming branch removal or SIMD.
- Prefer a disambiguating measurement over a broad rewrite.
- Never claim a speedup without before-and-after measurements.

## Output

Report:

1. workload and baseline
2. bottleneck classification with confidence
3. evidence and competing explanations
4. highest-value next measurement or minimal experiment
5. expected counter movement if the hypothesis is correct
6. correctness, portability, and maintainability risks

If evidence is insufficient, say so and request or collect the next decisive measurement.
