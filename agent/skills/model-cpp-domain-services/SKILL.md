---
description: "Structure C++ backend and enterprise services with explicit domain boundaries, command-query separation, repositories, transactional Units of Work, read models, and deployment helpers such as sidecars or backends-for-frontends. Use when persistence leaks into business logic, read and write workloads need different models, multiple changes require atomicity, or transport and infrastructure concerns obscure domain rules."
---
# Model C++ Domain Services

Separate domain decisions from persistence, transport, and deployment mechanics.

## Workflow

1. Identify domain invariants, commands, queries, aggregates, consistency needs, and external actors.
2. Keep simple CRUD simple; introduce patterns only for demonstrated complexity.
3. Read [references/domain-service-patterns.md](references/domain-service-patterns.md).
4. Define command results and query shapes independently when their needs differ.
5. Put persistence contracts at the domain/application boundary and implementations in infrastructure.
6. Define transaction ownership and consistency boundaries.
7. Decide how read models are updated and how staleness is exposed.
8. Test invariants, transaction failure, duplicate delivery, concurrency, and projection lag.

## Design Rules

- Keep repositories aggregate-oriented rather than mirroring every database table.
- Avoid a generic repository that erases useful query and transaction semantics.
- Make Unit of Work scope explicit; never hide ambient transactions in unrelated code.
- Use CQRS only when separate write and read models reduce real complexity or scaling pressure.
- Treat asynchronous projections as eventually consistent and expose that operationally.
- Make commands idempotent when delivery may repeat.
- Keep transport DTOs and database records out of the domain model.
- Use a sidecar for operational infrastructure only when its process boundary and failure behavior are acceptable.
- Use a backend-for-frontend only when clients have materially different orchestration or representation needs.

## Deliverable

Provide the domain boundary, command and query contracts, repository responsibilities, transaction scope, consistency model, failure behavior, and deployment-boundary rationale.
