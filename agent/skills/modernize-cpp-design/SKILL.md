---
name: modernize-cpp-design
description: Design and modernize C++17/20/23 APIs using explicit ownership and lifetime contracts, value semantics, RAII, focused error models, variants, callables, concepts, templates, type erasure, or justified virtual interfaces. Use when creating or reviewing a public API, refactoring inheritance or owning raw pointers, choosing static versus runtime polymorphism, simplifying GoF machinery, or making invalid states and failure behavior explicit.
---

# Modernize C++ Design

Refactor toward the simplest mechanism that satisfies the actual variability, ownership, ABI, and performance requirements.

## Workflow

1. Inspect the build standard, public ABI constraints, ownership and borrowing model, error model, extension model, and hot paths.
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
- Make ownership, borrowing, nullability, mutation, and lifetime visible in types and parameter choices.
- Prefer return values for outputs. Use result or exception conventions consistently and preserve diagnostic context.
- Use `std::variant` plus `std::visit` for a closed set of alternatives.
- Use a callable for one interchangeable operation.
- Use concepts or templates when implementations are known at compile time and code generation is acceptable.
- Use type erasure when runtime substitution matters but inheritance should stay out of the public model.
- Retain virtual interfaces for open runtime extension, stable object-oriented boundaries, or plugin contracts.
- Do not replace readable virtual dispatch with template machinery solely to avoid a virtual call.

## Refactoring Guardrails

- Preserve observable behavior before changing representation.
- Make ownership explicit; avoid introducing non-owning references that can dangle.
- Do not return views, spans, iterators, references, or callbacks whose source lifetime is unclear.
- Match `noexcept` to the real contract; do not use it to suppress or obscure failure.
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
- error, nullability, and invalid-state behavior;
- standard/library requirements;
- compatibility and performance consequences;
- tests or measurements performed.
