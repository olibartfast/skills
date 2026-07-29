---
description: "Modernize C++ designs by replacing unnecessary inheritance, virtual interfaces, owning raw pointers, and hand-written GoF machinery with value semantics, RAII, variants, callables, concepts, templates, or type erasure. Use when reviewing or refactoring C++17/20/23 APIs, choosing static versus runtime polymorphism, simplifying Visitor or Strategy implementations, or explaining whether a classic pattern is still justified."
---
# Modernize C++ Design

Refactor toward the simplest mechanism that satisfies the actual variability, ownership, ABI, and performance requirements.

## Workflow

1. Inspect the build standard, public ABI constraints, ownership model, extension model, and hot paths.
2. State which axes vary:
   - values or behavior;
   - closed or open set of types;
   - compile-time or runtime selection;
   - copyable or move-only state;
   - source-only or ABI-stable boundary.
3. Read [references/pattern-selection.md](references/pattern-selection.md).
4. Present at least two viable designs when requirements do not force one.
5. Implement the smallest coherent change when code changes are requested.
6. Compile and test the affected targets. Add focused tests for lifetime, dispatch, and unhandled alternatives.

## Selection Rules

- Prefer ordinary values and composition before polymorphism.
- Prefer RAII and the Rule of Zero for resource ownership.
- Use `std::variant` plus `std::visit` for a closed set of alternatives.
- Use a callable for one interchangeable operation.
- Use concepts or templates when implementations are known at compile time and code generation is acceptable.
- Use type erasure when runtime substitution matters but inheritance should stay out of the public model.
- Retain virtual interfaces for open runtime extension, stable object-oriented boundaries, or plugin contracts.
- Do not replace readable virtual dispatch with template machinery solely to avoid a virtual call.

## Refactoring Guardrails

- Preserve observable behavior before changing representation.
- Make ownership explicit; avoid introducing non-owning references that can dangle.
- Account for code size, compile time, error diagnostics, and ABI—not only runtime speed.
- Verify `std::function` copyability and allocation behavior before choosing it. Use `std::move_only_function` only when C++23 library support is available.
- Handle every `std::variant` alternative deliberately. Do not add a catch-all overload that masks missing domain cases.
- Keep concepts narrow and semantic. Avoid constraints that merely mirror an implementation.
- Measure before claiming a performance improvement.

## Deliverable

Report:

- the design pressure and constraints;
- the chosen mechanism and rejected alternatives;
- ownership and lifetime behavior;
- standard/library requirements;
- compatibility and performance consequences;
- tests or measurements performed.
