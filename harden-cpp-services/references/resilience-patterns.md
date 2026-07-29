# Resilience Patterns

Adapted from [Modern C++ Design Patterns Beyond GoF](https://olibartfast.ninja/blog/modern-cpp-design-patterns-beyond-gof.html).

## Pattern Matrix

| Failure pressure | Pattern | Essential policy |
|---|---|---|
| Slow dependency | Deadline/timeout | Bound total waiting time |
| Transient retry-safe failure | Backoff with jitter | Cap attempts and total budget |
| Persistently unhealthy dependency | Circuit breaker | Fail fast, then probe recovery |
| Shared resource exhaustion | Bulkhead | Separate capacity by failure domain |
| Excess offered load | Admission control/load shedding | Reject before queues collapse |
| Nonessential dependency unavailable | Graceful degradation | Make reduced behavior explicit |

## Retry Decision

Retry only when all are true:

- the failure is plausibly transient;
- repeating the operation is safe or protected by an idempotency mechanism;
- enough deadline remains for another useful attempt;
- the retry does not violate a rate or resource budget.

Do not retry validation failures, most authorization failures, deterministic capacity errors, or work whose caller has cancelled.

## Circuit Breaker State

- **Closed:** allow calls; record relevant failures and latency.
- **Open:** reject immediately until the recovery interval.
- **Half-open:** allow a bounded number of probes; close on demonstrated recovery or reopen on failure.

Define which outcomes count as failures. Do not let caller bugs or expected domain rejections poison dependency health.

## Bulkhead Design

Partition thread pools, connection pools, queue capacity, GPU streams/memory, or request concurrency when workloads have different criticality or dependencies. Reserve capacity where starvation is unacceptable. Revisit partitions using measurements; static isolation can waste capacity.

## Metrics and Tests

Track attempts, retry reasons, time spent backing off, breaker state changes, rejected work, partition saturation, deadline expiry, cancellations, and degraded responses.

Test:

- deterministic and transient failures;
- slow success beyond the useful deadline;
- recovery with concurrent callers;
- retry storms with many clients;
- half-open probe races;
- shutdown during backoff or in-flight I/O.
