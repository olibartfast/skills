---
description: "Add resilience to networked, cloud, edge, robotics, and distributed C++ systems with deadlines, bounded retries, exponential backoff with jitter, circuit breakers, bulkheads, admission control, and graceful degradation. Use when remote calls time out, retry storms occur, queues or thread pools saturate, GPU or connection resources are exhausted, or one subsystem can cascade failure into others."
---
# Harden C++ Services

Treat latency, overload, cancellation, and partial failure as part of the API contract.

## Workflow

1. Map call chains, dependency budgets, shared resources, idempotency, and failure modes.
2. Set an end-to-end deadline and allocate smaller downstream budgets.
3. Read [references/resilience-patterns.md](references/resilience-patterns.md).
4. Bound concurrency and queues before adding retries.
5. Add retries only for transient, retry-safe operations and only within the deadline.
6. Add circuit breaking when repeated calls to an unhealthy dependency waste scarce resources.
7. Partition critical resources with bulkheads when workloads have different priorities or failure domains.
8. Test overload, timeout, cancellation, recovery, half-open probes, and shutdown.

## Composition Rules

- Propagate deadlines and cancellation.
- Prefer time budgets over independent per-attempt timeouts.
- Use exponential backoff with jitter and a maximum delay.
- Cap attempts and total retry time.
- Respect server retry hints when trustworthy.
- Keep circuit-breaker state scoped to a meaningful dependency or endpoint.
- Limit half-open probes.
- Combine bulkheads with admission control; isolated unbounded queues still fail.
- Define degraded behavior instead of silently returning plausible stale data.

## C++ Guardrails

- Use monotonic clocks for elapsed time.
- Avoid detached threads and callbacks that outlive captured state.
- Make async operation ownership and executor affinity explicit.
- Ensure cancellation races cannot fulfill a promise or callback twice.
- Expose metrics without placing slow logging on the failure hot path.
- Do not hold locks across network or blocking operations.

## Deliverable

Provide a failure-mode table, deadline and retry budget, breaker state policy, resource partitions, degradation behavior, metrics, and fault-injection tests.
