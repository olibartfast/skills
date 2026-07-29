---
name: optimize-cuda-memory-locality
description: Design, implement, and review CUDA tiled and stencil kernels that use shared memory, registers, caches, halos, and coalesced global access. Use for matrix tiles, convolutions, PDE solvers, image filters, neighborhood operations, transposes, or any CUDA kernel whose performance depends on data reuse and memory locality.
---

# Optimize CUDA Memory Locality

Use tiling only when it creates measurable reuse or fixes a known access problem. Preserve correctness at tile edges and synchronization boundaries.

## Establish the Access Model

1. Draw the mapping from output coordinates to input coordinates.
2. Calculate bytes loaded/stored and useful operations per output.
3. Identify reuse distance, halo width, stride, alignment, and boundary behavior.
4. Record element type, layout, pitch, aliasing, and target GPU constraints.
5. Measure the untiled or library baseline before changing the kernel.

## Choose the Highest-Level Implementation

- Prefer cuBLAS or a suitable domain library for standard matrix operations.
- Prefer cuDNN or another maintained primitive for supported convolution workloads.
- Use CUTLASS or current supported matrix APIs when customization is necessary.
- Write a direct tiled kernel for unsupported operations, fusion, instruction, or layout needs.

Verify current architecture and Toolkit support before choosing Tensor Core instructions or asynchronous-copy features.

## Design the Tile

Calculate, rather than guess:

- output tile dimensions and threads per block;
- input tile dimensions including halo;
- dynamic/static shared-memory bytes;
- registers and work per thread;
- expected global transactions and reuse factor;
- occupancy constraints and whether they limit latency hiding.

Keep global accesses coalesced. Lay out shared memory to avoid harmful bank conflicts. Use padding only after identifying the conflict pattern. Do not maximize tile size or occupancy blindly.

## Load and Compute Safely

1. Assign every shared-memory element a loader, including halo and partial tiles.
2. Substitute a defined boundary value or branch according to the requested boundary policy.
3. Synchronize after cooperative loads and before overwriting storage still in use.
4. Keep every block-wide barrier on a path reached by all block threads.
5. Separate valid computation from valid storage when edge blocks contain inactive outputs.

For double-buffered or asynchronous copies, define buffer ownership and arrive/wait ordering explicitly. Maintain a simple synchronous version as a correctness baseline where practical.

## Handle Stencils

- State whether boundaries clamp, wrap, mirror, use constants, or remain unchanged.
- Avoid redundant halo loads only when the added coordination pays for itself.
- Consider separable passes for separable filters, including the intermediate-memory cost.
- Check temporal tiling for extra halo growth, register/shared-memory pressure, and changed numerical order.

## Validate and Profile

Test dimensions smaller than a tile, exact tile multiples, one-past multiples, non-square shapes, large halos, and odd pitches. Compare all boundaries against a trusted implementation.

Use `$profile-optimize-cuda` to verify global-memory sectors, cache behavior, shared-memory conflicts, achieved bandwidth, stalls, and resource pressure. Keep a change only when representative end-to-end performance improves.

## Sources

Base tiling and stencil selection on [Parallel Programming Pattern Fundamentals in CUDA](https://olibartfast.ninja/blog/cuda-parallel-programming-patterns.html). Resolve hardware and API details with the current [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-programming-guide/).
