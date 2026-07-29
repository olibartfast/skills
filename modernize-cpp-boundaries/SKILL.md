---
name: modernize-cpp-boundaries
description: Isolate legacy code, C APIs, vendor SDKs, drivers, protocols, and unstable third-party libraries behind modern C++ boundary adapters and anti-corruption layers, then migrate incrementally with a Strangler Fig approach. Use when unsafe handles, foreign data models, error codes, or vendor types leak into domain code, or when planning a low-risk legacy rewrite.
---

# Modernize C++ Boundaries

Keep foreign ownership, naming, errors, threading, and data models at the system edge.

## Workflow

1. Map the external surface: creation, destruction, calls, callbacks, threading, errors, data ownership, and versioning.
2. Identify which foreign concepts must not enter the domain.
3. Read [references/boundary-patterns.md](references/boundary-patterns.md).
4. Define a small internal port in domain language.
5. Implement an adapter that owns or borrows external resources explicitly.
6. Translate errors, data, time, identifiers, and callbacks at the boundary.
7. Add characterization and contract tests.
8. For migrations, route one capability at a time and retain an observable rollback path.

## Boundary Rules

- Wrap acquired resources in RAII types with correct deleters.
- Make invalid states unrepresentable where practical.
- Convert integer status codes into the project's established error model.
- Validate buffer sizes, encodings, alignment, ranges, nullability, and lifetimes.
- Never let callbacks capture objects whose lifetime is not synchronized with unregistration.
- Keep SDK headers and macros out of public domain headers.
- Do not expose foreign structs as the internal model merely to avoid translation.
- Preserve diagnostic context when translating errors.
- Document thread-safety and reentrancy explicitly.

## Migration Rules

- Characterize current behavior before replacement.
- Create a routing seam before writing the new implementation.
- Migrate vertical capabilities, not disconnected technical layers.
- Compare old and new results where shadow execution is safe.
- Define acceptance metrics and rollback triggers.
- Remove the old path only after callers, telemetry, and operational procedures have moved.

## Deliverable

Report the external hazards, internal port, ownership and error mapping, test strategy, migration increments, observability, and rollback plan.
