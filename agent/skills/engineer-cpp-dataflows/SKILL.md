---
name: engineer-cpp-dataflows
description: Design and review low-latency C++ pipelines for camera, audio, robotics, networking, streaming, and ML inference workloads using producer-consumer stages, bounded queues, backpressure, zero-copy ownership transfer, object pools, and double buffering. Use when throughput, tail latency, allocation, copying, queue growth, or stage isolation matters.
---

# Engineer C++ Dataflows

Design from data movement, ownership, and latency budgets rather than from class hierarchies.

## Workflow

1. Establish workload facts: item size, rate, burstiness, latency target, ordering, loss policy, and hardware affinity.
2. Diagram stages and record each stage's input, output, concurrency, and service-time distribution.
3. Read [references/dataflow-patterns.md](references/dataflow-patterns.md).
4. Define ownership transfer at every edge.
5. Choose bounded queue capacities and an explicit overload policy.
6. Define normal drain, cancellation, stage failure, queue close, and blocked-wakeup behavior before starting threads.
7. Select thread and cancellation facilities supported by the project's C++ standard.
8. Remove avoidable copies and hot-path allocation only where measurements justify it.
9. Instrument per-stage latency, queue depth, drops, stalls, allocation, and end-to-end percentiles.
10. Stress shutdown, overload, slow consumers, producer failure, and resource exhaustion.

## Required Decisions

- Decide whether each queue blocks, drops newest, drops oldest, coalesces, samples, or propagates backpressure.
- Decide whether ordering is global, per key, or unnecessary.
- Decide whether buffers are owned, borrowed, shared, or device-backed.
- Define cancellation and queue-closing semantics.
- Define whether blocked producers and consumers wake with a value, status, exception, or closed result.
- Bound memory use under the worst admissible burst.
- Define whether stale work remains valuable.

## Pattern Guardrails

- Prefer move-only ownership transfer for exclusive buffers.
- Use shared ownership only when consumers truly overlap; document the final-release thread.
- Do not call a design “zero-copy” if hidden device, serialization, color conversion, or API boundary copies remain.
- Use pools for expensive or latency-sensitive allocation, not automatically.
- Ensure pooled-handle deleters cannot outlive pool state.
- Use double buffering only when readers can tolerate snapshots and overwrite semantics are explicit.
- Avoid unbounded queues; they convert overload into latency and memory failure.
- Prevent false sharing and oversubscription when assigning threads.
- Prefer scoped thread ownership. Use `std::jthread` and stop tokens in C++20+ when they fit; otherwise provide an explicit stop state and guaranteed joins.
- Keep condition-variable predicates under the same mutex as the state they protect and notify every waiter affected by close or cancellation.
- Never detach pipeline threads to avoid designing shutdown.

## Deliverable

Include a stage diagram, queue contract table, ownership model, overload behavior, shutdown protocol, capacity rationale, and measured or expected bottlenecks.
