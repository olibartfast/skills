# C++ Testing Strategy

## Test Level Matrix

| Level | Best for | Avoid |
|---|---|---|
| Unit | Pure logic, invariants, parsing, transformations, small state machines | Rebuilding a large runtime graph |
| Component | One production component with controlled adapters | Mocking every internal method |
| Integration | Filesystems, runtimes, codecs, databases, processes, devices, and package boundaries | Duplicating all unit edge cases |
| End-to-end | Critical user workflows and deployment wiring | Broad combinatorial coverage |
| Property | Algebraic invariants, serialization round trips, ranges, and randomized structures | Unbounded or unreproducible generators |
| Concurrency | Queue, cancellation, shutdown, ownership, and race contracts | Timing assertions based on sleeps |
| Benchmark | Throughput, latency, allocation, and regression measurement | Treating faster output as correct output |

## Seam Selection

Prefer seams that also improve the production design:

- constructor-injected collaborators;
- narrow backend or boundary interfaces;
- filesystem paths and streams supplied by the caller;
- clocks, schedulers, and randomness as explicit dependencies when determinism matters;
- factories for expensive or environment-specific construction.

Do not make private methods public or add production-only mode flags solely for testing.

## Failure and Lifetime Matrix

Test:

- missing, malformed, empty, truncated, and oversized inputs;
- unsupported versions or capabilities;
- partial initialization followed by cleanup;
- exceptions or errors at every owned boundary;
- repeated initialization, execution, and teardown;
- moved-from and destruction ordering where observable;
- callbacks, worker threads, or handles still active during shutdown;
- cancellation while blocked, queued, or processing.

## Deterministic Concurrency

- Use barriers, latches, promises, controlled schedulers, or observable queue state to establish ordering.
- Define queue close, drain, cancellation, and blocked-wakeup semantics.
- Bound every wait and produce diagnostic state on timeout.
- Repeat stress cases under ThreadSanitizer when supported.
- Keep correctness assertions independent of which valid thread wins a race.

## Benchmark Integrity

Verify representative inputs, warmup, iteration count, compiler flags, affinity when relevant, dead-code-elimination protection, and result correctness. Report distributions or robust summaries rather than a single timing.
