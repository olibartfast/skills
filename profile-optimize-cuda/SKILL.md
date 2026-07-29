---
name: profile-optimize-cuda
description: Profile, diagnose, and optimize CUDA applications and kernels with evidence from Nsight Systems, Nsight Compute, benchmarks, and correctness tests. Use for slow CUDA code, low utilization, memory or compute bottlenecks, occupancy questions, divergence, launch overhead, poor transfer overlap, optimization reviews, or performance regressions.
---

# Profile and Optimize CUDA

Optimize the measured bottleneck, preserve correctness, and report uncertainty. Do not infer a kernel bottleneck from source alone when profiling is available.

## Establish a Reproducible Baseline

Record:

- GPU model, driver, CUDA Toolkit, build type, compiler flags, clocks/power constraints, and relevant environment;
- representative inputs, warmup, iteration count, synchronization boundaries, and timing method;
- end-to-end latency/throughput and per-stage or per-kernel time;
- correctness oracle, tolerance, and determinism expectations.

Use release-like code with debug line information only as needed. Separate one-time initialization and JIT costs from steady state.

## Diagnose Top Down

1. Use a timeline profiler such as Nsight Systems to locate CPU gaps, transfers, launches, synchronization, stream overlap, and the kernels that dominate end-to-end time.
2. Use Nsight Compute only on selected kernels or ranges.
3. Start with a lightweight section set, then collect deeper metrics for a concrete hypothesis.
4. Compare profiles from the same workload and environment; profiler replay and collection overhead can perturb execution.

## Classify the Limiter

Examine:

- arithmetic intensity and roofline position;
- achieved memory bandwidth, transactions, cache behavior, and access efficiency;
- compute-pipeline utilization and instruction mix;
- eligible/active warps, stall reasons, divergence, and load imbalance;
- registers, shared memory, spills, theoretical versus achieved occupancy;
- launch count, duration, transfer behavior, and synchronization gaps.

Treat occupancy as a latency-hiding diagnostic. Higher occupancy does not automatically mean higher performance.

## Form and Test One Hypothesis

Map evidence to a change:

- reduce bytes or improve locality for a memory-traffic limit;
- improve coalescing or remove replay/transaction waste for an access-efficiency limit;
- increase reuse or use an appropriate library/instruction path for a compute limit;
- reduce divergence or rebalance work for execution inefficiency;
- fuse, batch, pipeline, or use graphs for launch/transfer overhead;
- reduce resource pressure only when it limits active work or causes spills.

Change one meaningful factor, rerun correctness tests, benchmark repeatedly, and compare confidence intervals or robust summary statistics. Revert changes that only move a secondary metric without improving the user-visible goal.

## Report Findings

Provide:

1. Reproduction command and environment.
2. Baseline with measurement method and variability.
3. Dominant bottleneck and metrics supporting it.
4. Optimization, its predicted mechanism, and tradeoffs.
5. Before/after end-to-end and kernel measurements.
6. Correctness and regression results.
7. Remaining uncertainty and the next falsifiable experiment.

Use `$select-cuda-parallel-patterns` when evidence indicates the algorithmic pattern should change.

## Sources

Base the optimization categories on [Parallel Programming Pattern Fundamentals in CUDA](https://olibartfast.ninja/blog/cuda-parallel-programming-patterns.html). Use the current [Nsight Systems documentation](https://docs.nvidia.com/nsight-systems/), [Nsight Compute profiling guide](https://docs.nvidia.com/nsight-compute/ProfilingGuide/), and [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-programming-guide/) for tool and metric semantics.
