---
name: author-cpu-optimization-lab
description: Create or extend hands-on C++17 CPU optimization labs with deterministic baselines, optimized variants, CMake targets, correctness checks, profiling instructions, and measurable learning goals. Use for teaching branch prediction, cache locality, SIMD, memory bandwidth, data layout, ILP, TLB behavior, or other modern CPU performance concepts.
---

# Author a CPU Optimization Lab

Build an experiment that teaches one dominant CPU concept through controlled comparison.
Optimize for learning value, reproducibility, and correctness.

## Workflow

1. State one learning goal and the hardware behavior it demonstrates.
2. Define the problem, allowed transformations, forbidden shortcuts, and correctness oracle.
3. Create a baseline plus only the variants needed to isolate the concept.
4. Use deterministic data generation and fixed seeds. Keep timed regions free of I/O and setup.
5. Prevent dead-code elimination with an observable result, and validate every variant against
   the oracle before timing it.
6. Build separate optimization levels when they reveal the compiler's role.
7. Provide standalone binaries for profiler isolation and an all-variants comparison runner.
8. Document exact build, run, and profiling commands.
9. State expected qualitative trends, not fabricated universal timings.
10. Run correctness tests and representative benchmarks when the environment permits.

Read [references/lab-design-guide.md](references/lab-design-guide.md) before creating files or
choosing metrics.

## Repository Adaptation

- Inspect the target repository's `AGENTS.md`, build system, naming, and existing labs first.
- Follow local conventions when they conflict with the example layout in the reference.
- Update the root catalog and agent guidance when adding a lab changes documented structure.
- Mark future topics as planned; do not present unimplemented labs as runnable.

## Output

Produce or describe:

1. learning goal and hypothesis
2. directory and target layout
3. baseline, variants, and correctness oracle
4. benchmark methodology
5. counters that should distinguish the variants
6. build and profiling commands
7. expected observations and interpretation
8. documentation updates
