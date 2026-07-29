---
name: coordinate-cuda-thread-groups
description: Implement and review CUDA warp-level primitives, Cooperative Groups, block or grid collectives, synchronization, ballots, shuffles, persistent kernels, and producer-consumer coordination. Use when CUDA threads exchange values or synchronize within a warp, subgroup, block, cluster, or grid, especially around divergence and collective participation.
---

# Coordinate CUDA Thread Groups

Make the participant set explicit before using a collective or barrier. Treat synchronization as a correctness contract, not only a performance tool.

## Define Scope and Participants

1. Choose the smallest required scope: lane subset, warp, tile, block, cluster, or grid.
2. Identify which threads reach each collective and whether divergence changes that set.
3. Define data ownership and the memory visibility required across the synchronization point.
4. Confirm compute capability, launch requirements, residency limits, and Toolkit support for non-block scopes.

Prefer kernel boundaries when wider synchronization is infrequent and fusion does not justify the added constraints.

## Use Warp-Level Primitives Safely

- Derive a mask that exactly names participating active lanes; do not use a full mask when some named lanes may not execute the intrinsic.
- Call a given collective with compatible masks and control flow across all named lanes.
- Pass width/source-lane parameters that cannot read an unintended logical subgroup.
- Use ballot for predicates, shuffle for register exchange, and match operations only when their semantics fit.
- Insert the appropriate warp synchronization when shared/global memory communication requires ordering or visibility.
- Test partial warps and divergent paths; avoid relying on implicit lockstep behavior.

Use maintained warp collectives from CUB or Cooperative Groups when they express the operation cleanly.

## Use Cooperative Groups Safely

- Create implicit group handles early, before branches, where recommended.
- Pass group handles by reference.
- Treat partitioning and collectives as collective operations: every required parent/group member must participate.
- Use specialized, statically sized groups when they improve correctness and compile-time optimization.
- Keep group synchronization paired with the memory communication it protects.

For grid-wide synchronization, verify cooperative-launch support and that the entire grid can be resident under the chosen resource usage. Provide a multi-kernel fallback when portability or grid size requires it.

## Review Persistent and Producer-Consumer Kernels

Define:

- work-queue ownership and atomic ordering;
- termination detection with no lost work;
- backpressure and bounded buffering;
- fairness and forward-progress assumptions;
- barrier phase reuse and memory-order semantics;
- behavior under oversubscription and skew.

Do not introduce a persistent kernel without comparing it with ordinary launches or CUDA Graphs.

## Validate

Run race checking and synchronization checking when available. Test partial groups, empty work, divergent branches, maximum grid sizes, skewed producers, and multiple architectures. Surface launch failures and unsupported cooperative configurations.

Use `$profile-optimize-cuda` to quantify barrier stalls, divergence, eligible warps, register pressure, and whether reduced memory traffic offsets coordination cost.

## Sources

Base the pattern vocabulary on [Parallel Programming Pattern Fundamentals in CUDA](https://olibartfast.ninja/blog/cuda-parallel-programming-patterns.html). Use the current [Cooperative Groups guide](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/cooperative-groups.html) and [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-programming-guide/) for version-sensitive rules.
