---
name: test-cpp-software
description: Design, implement, and review risk-based tests for C++17/20/23 libraries and applications using unit, component, integration, property, concurrency, and benchmark tests. Use when planning coverage for a feature or refactor, creating test seams, choosing fakes versus mocks, reproducing a defect, testing failure paths and lifetimes, reducing flaky tests, or deciding which behaviors belong at each test level.
---

# Test C++ Software

Test observable contracts at the cheapest level that provides confidence. Let risk, ownership, concurrency, and integration boundaries determine the test mix.

## Workflow

1. Identify changed behavior, invariants, public contracts, failure modes, ownership transitions, concurrency, and external boundaries.
2. Inspect the existing framework, fixtures, test target structure, CI runtime, and sanitizer coverage.
3. Read [references/testing-strategy.md](references/testing-strategy.md).
4. Map each material risk to one primary test level.
5. Create seams at existing architectural boundaries; do not distort production APIs solely for tests.
6. Add deterministic success, boundary, failure, and regression cases.
7. Control time, randomness, scheduling, files, networks, and environment state.
8. Run the narrow tests first, then the relevant integration and quality gates.

## Test Rules

- Test behavior and invariants rather than private implementation steps.
- Prefer small fakes or direct values over mocks when state-based verification is clearer.
- Use mocks for important interaction contracts, not incidental call order.
- Keep a scalar, synchronous, or otherwise trusted oracle for optimized implementations.
- Test empty, minimum, maximum, malformed, partial, and mismatched inputs where the contract permits them.
- Verify construction failure, partial initialization, destruction, cancellation, and repeated use for resource-owning code.
- Never use arbitrary sleeps as proof of concurrency ordering.
- Keep benchmarks separate from correctness assertions while validating benchmark results against a trusted implementation.
- A test added for a defect must fail for the original cause, not merely exercise the changed line.

## Deliverable

Provide the risk-to-test mapping, selected levels and seams, deterministic controls, fixtures and oracles, failure and boundary cases, commands run, and any residual untested risk.
