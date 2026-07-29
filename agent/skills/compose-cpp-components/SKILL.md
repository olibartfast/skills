---
name: compose-cpp-components
description: Design explicit dependency graphs and runtime extension points in C++ using constructor injection, composition roots, factory registries, plugin boundaries, and narrowly controlled service lookup. Use when wiring C++ applications, removing globals or Service Locators, making code testable, selecting implementations by configuration, or designing plugin and backend registries.
---

# Compose C++ Components

Make required dependencies visible and centralize object construction.

## Workflow

1. Inventory components, dependencies, ownership, lifetimes, thread affinity, and startup order.
2. Classify each dependency as required, optional, collection, factory, or runtime-discovered.
3. Draw the object graph and mark its composition root.
4. Read [references/composition-patterns.md](references/composition-patterns.md).
5. Select constructor injection by default.
6. Introduce factories only where construction varies or must be deferred.
7. Decide whether implementation selection belongs at configure time, process startup, or runtime discovery.
8. Introduce registries or plugins only where runtime discovery is a real requirement.
9. Compile and test startup, shutdown, missing registrations, duplicate registrations, unsupported capabilities, and test substitution.

## Design Rules

- Pass required dependencies through constructors.
- Represent optional dependencies explicitly; do not encode absence as an unvalidated null pointer.
- Keep construction and configuration outside business logic.
- Give the composition root responsibility for ownership and destruction order.
- Use references for required non-owning dependencies whose lifetime is guaranteed.
- Use smart pointers only when ownership semantics require them.
- Keep registry keys, supported capabilities, creation failures, and duplicate behavior explicit.
- Keep plugin ABI boundaries narrow and versioned. Avoid exporting STL types across unknown toolchain or runtime boundaries.
- For compile-time-selected backends, keep one stable consumer interface and reject invalid backend combinations during configuration.
- For runtime selection, validate model, protocol, device, or file-format compatibility before expensive initialization.

## Service Lookup Policy

Treat Service Locator as a constrained exception:

- permit it for legacy seams, runtime plugin discovery, or carefully scoped diagnostics;
- prohibit it for required domain dependencies;
- wrap access behind a narrow interface;
- define initialization, concurrency, replacement, failure, and teardown behavior;
- migrate hidden dependencies toward injection when touching affected code.

Do not replace many explicit parameters with a grab-bag context object unless those values form a cohesive abstraction.

## Backend Selection

- Use compile-time selection when a backend changes toolchains, binary dependencies, licensing, deployment size, or supported platforms.
- Use startup-time selection when multiple implementations can safely coexist in one binary and configuration determines the choice.
- Use runtime discovery only when third parties or deployed modules must register implementations.
- Keep backend-specific headers, definitions, and construction outside consumers.
- Give test code a direct injection path that bypasses environmental discovery.

## Deliverable

Provide:

- a dependency inventory and ownership map;
- the composition root location;
- the selected injection and discovery mechanisms;
- lifecycle and error behavior;
- a migration sequence when removing globals;
- focused tests for construction and teardown.
