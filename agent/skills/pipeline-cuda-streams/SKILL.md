---
description: "Design, implement, debug, and review CUDA stream pipelines that overlap host/device transfers, kernels, and independent work. Use for cudaMemcpyAsync, pinned host memory, events, stream ordering, double or triple buffering, multi-stream execution, CUDA Graphs, default-stream hazards, or end-to-end throughput and latency tuning."
---
# Pipeline CUDA Streams

Build asynchronous pipelines from an explicit dependency graph. Distinguish enqueue time from completion time and requested concurrency from concurrency actually observed.

## Map Dependencies

1. List every host task, transfer, kernel, allocation, and result consumer.
2. Draw true data dependencies and ownership/lifetime boundaries.
3. Mark operations that can overlap and resources that may serialize them.
4. Record chunk size, transfer direction, latency/throughput target, and target GPU copy-engine capabilities.
5. Measure a correct single-stream baseline.

## Implement the Pipeline

- Use page-locked host buffers when host/device copies must overlap; budget pinned memory because excessive pinning harms the system.
- Enqueue dependent operations in one stream or connect streams with recorded events and `cudaStreamWaitEvent`.
- Use nonblocking streams or per-thread default-stream behavior deliberately; avoid accidental legacy default-stream synchronization.
- Keep buffers, events, streams, and temporary storage alive until all consuming work completes.
- Avoid device-wide synchronization in the steady-state loop.
- Check enqueue/launch errors promptly and check asynchronous completion errors at a defined boundary.

For double or triple buffering, assign each slot a state such as free → copying in → computing → copying out → free. Never reuse a slot until its completion event proves all consumers are done.

## Choose Granularity

Balance:

- chunks large enough to amortize launch and transfer overhead;
- enough in-flight work to cover pipeline stages;
- bounded memory footprint and acceptable tail latency;
- kernel duration and resource use that permit useful overlap.

Do not split work merely to increase stream count. Too-small chunks and competing kernels can reduce throughput.

## Consider CUDA Graphs

Use CUDA Graphs when a stable launch topology repeats and CPU launch overhead is material. Define which parameters and addresses change between replays, update rules, capture restrictions, and resource lifetimes. Keep ordinary-stream behavior as a correctness baseline.

## Validate and Measure

Test one chunk, partial final chunks, multiple in-flight slots, early errors, teardown, and back-to-back invocations. Use events for device elapsed time and a host clock for end-to-end latency; do not include asynchronous work accidentally outside the timed interval.

Use a timeline profiler to confirm overlap and expose gaps, implicit synchronization, pageable transfers, serialized resources, or host stalls. Report both steady-state throughput and startup/drain costs.

Use `$profile-optimize-cuda` when a kernel inside the pipeline, rather than scheduling, is the bottleneck.

## Sources

Base stream parallelism on [Parallel Programming Pattern Fundamentals in CUDA](https://olibartfast.ninja/blog/cuda-parallel-programming-patterns.html). Resolve ordering and overlap rules with the current [CUDA asynchronous execution guide](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/asynchronous-execution.html).
