# Dataflow Patterns

Adapted from [Modern C++ Design Patterns Beyond GoF](https://olibartfast.ninja/blog/modern-cpp-design-patterns-beyond-gof.html).

## Stage Contract

Record this for every edge:

| Field | Questions |
|---|---|
| Payload | What data and metadata cross the edge? |
| Ownership | Move, borrow, share, device handle, or copy? |
| Capacity | How many items and bytes can queue? |
| Overload | Block, reject, drop, coalesce, sample, or shed upstream? |
| Ordering | Global, per stream/key, or none? |
| Freshness | When does queued work become useless? |
| Shutdown | How are close, drain, cancel, and failure represented? |

## Pattern Selection

### Producer-Consumer Pipeline

Use when stages have distinct work, rates, or hardware affinity. Keep queues bounded. Measure service time and queue wait separately.

### Ownership-Passing Pipeline

Move a `std::unique_ptr`, move-only buffer handle, or owning value when exactly one stage owns the payload at a time. Borrow only with a lifetime protocol stronger than the queue lifetime.

### Object Pool

Use when allocation is expensive, fragmented, or visible in tail latency. Bound the pool, define exhaustion behavior, reset objects completely, and ensure handles cannot call a destroyed pool. Prefer a shared control block when returned handles may outlive the facade.

### Double Buffering

Use for snapshot-style communication between one writer and readers when replacing the current state is acceptable. Define synchronization, swap visibility, and whether readers can retain the old buffer.

## Capacity Heuristics

- Start from the admissible burst and end-to-end latency budget.
- Capacity in items is insufficient when payload sizes vary; enforce a byte budget too.
- Queue occupancy is stored latency. A long queue can improve throughput while violating freshness.
- Prefer rejecting work early when the downstream result would already miss its deadline.

## Shutdown Protocol

Define the state machine before implementing the queue:

1. Running accepts pushes and permits pops.
2. Closing rejects new work and either drains or cancels queued work according to policy.
3. Closed wakes every blocked producer and consumer.
4. Stage failure records one observable cause and triggers the chosen downstream and upstream cancellation behavior.
5. Owners request stop, close queues, and join every thread in an order that cannot deadlock.

For C++20 and later, `std::jthread` and stop tokens can simplify scoped thread ownership but do not replace queue-close semantics. For C++17, pair an explicit stop state with condition-variable predicates and deterministic joins. In either case, test close while empty, close while full, blocked push, blocked pop, failure in each stage, repeated stop requests, and teardown with work in flight.

## Verification

- Measure p50, p95, p99, and maximum end-to-end latency.
- Track per-stage CPU/device time, wait time, queue depth, drops, and allocation.
- Test rates above steady-state capacity.
- Stall each consumer independently.
- Cancel during push, pop, processing, and shutdown.
- Establish concurrency order with barriers, latches, promises, or observable state rather than arbitrary sleeps.
- Run sanitizers appropriate to the codebase and stress lifetime transitions.
