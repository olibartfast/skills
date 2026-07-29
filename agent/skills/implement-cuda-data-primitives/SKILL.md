---
description: "Implement and review CUDA reductions, inclusive or exclusive scans, maps/transforms, gathers, scatters, histograms, and related compaction or partition primitives. Use for CUDA C++ kernels or CCCL/CUB/Thrust code involving aggregate, prefix, element-wise, or indirect indexed operations, including correctness, numerical stability, contention, and performance work."
---
# Implement CUDA Data Primitives

Implement aggregate and indexed operations with explicit semantics, safe participation, and library-first choices.

## Define Semantics First

Record:

- input/output lengths, types, layouts, aliasing, and empty-input behavior;
- inclusive versus exclusive scan and the identity value;
- reduction operator, associativity assumptions, numerical tolerance, overflow policy, and determinism;
- valid index range and duplicate-index semantics for gather/scatter;
- histogram bin range, counter width, reset behavior, and expected contention.

Reject an implementation whose parallel reassociation violates required semantics.

## Choose the Implementation Level

1. Prefer CCCL/CUB device primitives for production reductions and scans.
2. Prefer block or warp CUB primitives inside larger fused kernels.
3. Consider Thrust when its iterator model, execution policy, synchronization, allocation, and stream behavior fit the surrounding code.
4. Write a custom kernel only when fusion or unsupported semantics justify the maintenance and tuning cost.

Follow each library API's two-phase temporary-storage contract where applicable. Reuse temporary storage rather than allocating it in a hot loop.

## Implement by Pattern

### Map

- Use a grid-stride loop when inputs may exceed one grid or when launch reuse is useful.
- Make adjacent participating threads access adjacent elements where possible.
- Fuse adjacent element-wise stages only after checking register pressure, code size, and lost reuse.

### Reduction

- Reduce hierarchically: thread → warp → block → device.
- Use the correct identity for inactive lanes and tail elements.
- Avoid placing a block-wide barrier in a path not reached by every block thread.
- Accumulate in a wider or compensated type when numerical requirements demand it.
- Avoid assuming floating-point results are bitwise stable across decompositions.

### Scan

- Preserve inclusive/exclusive semantics and the initial value exactly.
- Use a device primitive for cross-block scan unless a custom implementation has a proven need and a sound inter-block protocol.
- Test non-power-of-two sizes, zero/one elements, segmented boundaries if present, and in-place operation if supported.

### Gather, Scatter, and Histogram

- Validate or deliberately mask indirect indices before memory access.
- Define what duplicate destinations mean. Use atomics, sorting/reduction by key, or ownership partitioning accordingly.
- Reduce global atomic contention with warp aggregation or block-private bins only when distribution and resource use justify it.
- Avoid silent counter overflow and initialize output state explicitly.

## Review Correctness

Check:

- every collective has the same participating threads and compatible masks;
- all shared-memory reads are preceded by required writes and synchronization;
- all global outputs have one owner or a defined atomic conflict rule;
- kernel launch and asynchronous API errors are surfaced;
- temporary buffers remain alive until stream work completes.

Test adversarial sizes around warp and block boundaries, skewed bins, repeated indices, NaNs/Infs where relevant, and multiple streams.

## Measure

Compare against a trusted CPU or library implementation, then benchmark representative distributions and sizes. Use `$profile-optimize-cuda` when optimization is evidence-driven rather than a straightforward implementation.

## Sources

Base the pattern vocabulary on [Parallel Programming Pattern Fundamentals in CUDA](https://olibartfast.ninja/blog/cuda-parallel-programming-patterns.html). Resolve APIs with current [CCCL/CUB documentation](https://nvidia.github.io/cccl/cub/) and semantics with the [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-programming-guide/).
