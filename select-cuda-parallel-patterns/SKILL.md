---
name: select-cuda-parallel-patterns
description: Select and compose CUDA parallel programming patterns for a GPU workload. Use when planning, explaining, or reviewing a CUDA algorithm; deciding among map, reduction, prefix scan, tiling, stencil, gather/scatter, warp collectives, cooperative groups, and stream parallelism; or deciding whether to use an NVIDIA library instead of a custom kernel.
---

# Select CUDA Parallel Patterns

Turn workload semantics into a library choice, execution decomposition, memory plan, and validation strategy.

## Start With Constraints

1. Identify the input/output shapes, data types, reduction operators, ordering requirements, and boundary conditions.
2. Identify dependencies: independent elements, neighbors, prefixes, global aggregates, or indirect indices.
3. Estimate reuse, arithmetic intensity, transfer volume, skew, sparsity, and write contention.
4. Record the target GPU, CUDA Toolkit version, latency/throughput goal, numerical tolerance, and determinism requirement.
5. Inspect existing code, tests, build settings, and profiler evidence before proposing a rewrite.

Do not invent architecture-specific limits. Query the device or consult the matching current NVIDIA documentation.

## Prefer Maintained Libraries

Choose a maintained NVIDIA primitive when it expresses the operation:

- Use CCCL/CUB for device-, block-, warp-, and thread-level reductions and scans.
- Use Thrust for high-level transforms, scans, reductions, and indexed algorithms when its abstraction and allocation behavior fit.
- Use cuBLAS, cuDNN, cuFFT, cuSPARSE, or another domain library for standard dense, neural-network, Fourier, or sparse operations.
- Write a custom kernel only for fusion, unusual semantics, unsupported layouts, or demonstrated performance needs.

Include library integration, temporary-storage ownership, stream use, and error handling in the design.

## Select Patterns

| Workload property | Primary pattern | Main concern |
| --- | --- | --- |
| Independent element transform | Map | Coalesced access and useful work per launch |
| Many values to one | Reduction | Associativity, numerical behavior, hierarchy |
| Every output depends on a prefix | Inclusive/exclusive scan | Exact scan semantics and synchronization |
| Repeated local data reuse | Tiling | Tile shape, halo, bank conflicts, occupancy |
| Fixed or structured neighborhood | Stencil | Halo loading and boundary policy |
| Indirect reads | Gather | Locality and index validation |
| Indirect writes | Scatter/histogram | Collisions, atomics, privatization |
| Communication inside a warp | Warp collective | Active mask and participation |
| Explicit subgroup/block/grid coordination | Cooperative groups | Collective participation and launch support |
| Transfer/compute overlap | Streams | Dependencies, pinned memory, pipeline balance |

Compose patterns when needed. For example, use map → block reduction → device reduction, or tiled stencil → stream pipeline. State intermediate buffers, synchronization boundaries, and fusion tradeoffs.

## Produce an Implementable Plan

Provide:

1. Chosen library or kernel pattern and rejected alternatives.
2. Grid/block mapping and per-thread work.
3. Global/shared/register data movement and synchronization.
4. Boundary, empty-input, aliasing, contention, and overflow handling.
5. Correctness tests against a CPU or trusted implementation.
6. Baseline and target metrics, with a profiling experiment that can falsify the optimization claim.

Use `$implement-cuda-data-primitives`, `$optimize-cuda-memory-locality`, `$coordinate-cuda-thread-groups`, `$pipeline-cuda-streams`, or `$profile-optimize-cuda` for the focused implementation or diagnosis.

## Sources

Base the pattern vocabulary on [Parallel Programming Pattern Fundamentals in CUDA](https://olibartfast.ninja/blog/cuda-parallel-programming-patterns.html). Resolve version-sensitive details with the current [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-programming-guide/) and [CCCL documentation](https://nvidia.github.io/cccl/).
