# CPU Bottleneck Guide

## Contents

- Benchmark preflight
- Classification map
- Counter formulas
- Controlled experiments
- Interpretation cautions

## Benchmark preflight

Before interpreting hardware counters, verify:

- identical inputs and output correctness
- release binaries with recorded compiler and flags
- enough work to dominate startup and timer overhead
- repeated samples with median and dispersion
- fixed CPU affinity and stable frequency when feasible
- no debug logging or allocation accidentally inside the timed region
- an observable sink that prevents dead-code elimination

Use a standalone binary for each variant when profiling. Mixed runners can contaminate branch
history, cache state, and aggregate counters.

## Classification map

| Signal | Supporting evidence | Competing explanation | Next experiment |
|---|---|---|---|
| High branch misses or Branch MPKI | data-dependent control flow, lower IPC | profiler counts harness branches | isolate the kernel; compare sorted or branchless input |
| High L1D/LLC misses | large or irregular working set | compulsory cold misses | sweep sizes across cache capacities |
| High memory latency, low bandwidth | dependent misses, pointer chasing | insufficient work | use latency analysis; flatten or batch independent accesses |
| High bandwidth near platform limit | streaming workload | measurement multiplexing | reduce bytes per item or improve reuse |
| High dTLB misses | large page working set, random page access | cache misses correlated with pages | sweep pages separately from bytes; improve page locality |
| Frontend stalls, L1I or BTB pressure | large hot code, many targets | backend starvation | shrink/unify hot code and compare instruction footprint |
| Low IPC with low cache/branch misses | dependency chain, port pressure, ROB limits | frequency throttling | inspect assembly and top-down metrics |
| Scalar code for data-parallel loop | vectorization report rejects loop | SIMD unprofitable for small trips | remove one blocker and inspect assembly |

Classifications can overlap. For example, pointer chasing may create cache misses, low
memory-level parallelism, TLB pressure, and low IPC simultaneously. Name the causal bottleneck,
not every downstream symptom.

## Counter formulas

Use normalized metrics to compare implementations with different instruction counts:

```text
IPC = instructions / cycles
MPKI = misses * 1000 / instructions
branch miss rate = branch-misses / branches
```

Example Linux starting point:

```bash
perf stat -r 5 -e cycles,instructions,branches,branch-misses,cache-references,cache-misses -- ./bench
perf record -g -- ./bench
perf report
```

Use architecture-specific event names only after checking `perf list`. Multiplexed events,
virtual machines, kernel restrictions, hybrid P/E cores, and frequency scaling can distort
results.

## Controlled experiments

### Branch prediction

- Keep values and work constant; change only outcome ordering.
- Compare random order with partitioned or sorted order.
- Compare explicit branching with a semantically equivalent branchless form.
- Inspect assembly: a ternary may still branch, and an `if` may vectorize.
- Include preprocessing in end-to-end time unless it is legitimately amortized.

### Cache locality

- Sweep working-set size through expected L1, L2, LLC, and DRAM regimes.
- Compare sequential, strided, and random access with the same useful work.
- Compare AoS and SoA only for the fields the kernel actually consumes.
- Tile multidimensional loops and sweep tile sizes rather than assuming one cache size.

### Memory latency and MLP

- Distinguish bandwidth saturation from serial dependent misses.
- Batch independent lookups to expose memory-level parallelism.
- Prefetch only predictable future addresses and measure pollution as well as benefit.
- Avoid software prefetching for short, cache-resident, or unpredictable traversals.

### IPC, ILP, and out-of-order execution

- Inspect dependency chains in assembly.
- Use multiple independent accumulators as a controlled ILP experiment.
- Watch code size and register pressure when unrolling.
- Treat high ROB occupancy as context-dependent; use top-down analysis to locate the stall.

### Frontend

- Compare hot instruction footprint and indirect-target count.
- Separate rare paths from common paths.
- Avoid inlining large cold functions into the hot loop.
- Measure L1I, instruction-TLB, decode, and BTB signals when supported.

### TLB

- Sweep the number of pages while holding accesses per page controlled.
- Improve page locality before considering huge pages.
- Treat huge pages as an environment-dependent optimization with operational tradeoffs.

## Interpretation cautions

- Sorting is not a universal branch optimization; it changes order and costs time.
- Branchless code can do extra work and lose when a branch is highly predictable.
- A lower miss percentage can accompany worse total time if instruction count rises.
- `-O0` teaches source behavior but is not representative of production compiler behavior.
- `-O3 -mavx2` is not portable to every CPU; compile and dispatch according to the deployment
  contract.
- Typical cache and misprediction latencies are illustrative, not constants.
- Always validate the actual target architecture.
