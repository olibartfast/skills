# Domain and Service Patterns

Adapted from [Modern C++ Design Patterns Beyond GoF](https://olibartfast.ninja/blog/modern-cpp-design-patterns-beyond-gof.html).

## Pattern Selection

| Need | Pattern | Do not use merely because |
|---|---|---|
| Domain-oriented persistence access | Repository | Every table needs an interface |
| Atomic changes across a consistency boundary | Unit of Work | Transactions should be invisible |
| Distinct write invariants and read shapes | CQRS | Reads and writes have different method names |
| Operational helper beside a service | Sidecar | Packaging it separately seems fashionable |
| Client-specific orchestration | Backend-for-Frontend | Two clients exist |

## Repository

Expose operations meaningful to the domain or aggregate. Keep query capabilities explicit. Define not-found behavior, optimistic concurrency, identity handling, and transaction participation. Avoid returning lazy database objects whose lifetime leaks infrastructure concerns.

## Unit of Work

Define:

- who begins, commits, and rolls back;
- which repositories participate;
- whether nested operations join or reject the current unit;
- how concurrency conflicts are surfaced;
- what happens after a failed commit.

Keep transaction lifetime short and visible at the application-operation boundary.

## CQRS

Separate commands from queries when the write model protects complex invariants while reads require different denormalized or cache-friendly shapes. Define:

- command idempotency and result semantics;
- event/outbox behavior if projections update asynchronously;
- acceptable projection lag;
- read-your-writes expectations;
- replay and rebuild procedures.

CQRS does not require event sourcing or separate databases.

## Deployment Helpers

A sidecar can isolate telemetry, proxying, TLS, or service discovery, but adds a network/process failure boundary and operational coupling.

A backend-for-frontend can tailor aggregation, authorization, and representation for a client family, but duplicates orchestration if boundaries are weak. Keep core domain policy behind shared service contracts.

## Review Questions

1. Where is each invariant enforced?
2. What is the atomic consistency boundary?
3. Can a command be delivered twice?
4. How stale may a query result be?
5. Which layer owns retries and transactions?
6. What operational failure does a new process boundary introduce?
