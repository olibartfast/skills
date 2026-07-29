---
name: engineer-modern-cmake
description: Design, review, and refactor maintainable CMake builds for C++17/20/23 projects using target-based usage requirements, explicit options, optional components, presets, generated configuration, installation, and package exports. Use when CMakeLists.txt has global flags or include paths, transitive dependency problems, selectable backends, duplicated configuration, fragile tests, or unclear build and install interfaces.
---

# Engineer Modern CMake

Model the build as a graph of targets with explicit requirements. Keep configuration choices visible and make invalid combinations fail early.

## Workflow

1. Inspect the minimum CMake version, C++ standard, supported generators, platforms, toolchains, package managers, install requirements, and CI entry points.
2. Inventory libraries, executables, tests, generated files, optional components, and external dependencies.
3. Read [references/cmake-design-guide.md](references/cmake-design-guide.md).
4. Separate build-time choices from runtime configuration.
5. Express compile features, definitions, include paths, link libraries, and sources on the narrowest owning target.
6. Validate option combinations during configure and print actionable diagnostics.
7. Preserve existing consumer and install interfaces unless a breaking change is authorized.
8. Configure, build, test, install, and consume the affected targets with representative presets or toolchains.

## Design Rules

- Prefer targets and usage requirements over directory-wide state.
- Use `PRIVATE`, `PUBLIC`, and `INTERFACE` according to the consumer contract, not convenience.
- Prefer `target_compile_features` over forcing compiler flags for the language standard.
- Keep platform, compiler, backend, and feature conditions close to the targets they affect.
- Represent mutually exclusive or dependent options explicitly and reject invalid matrices.
- Use imported or namespaced targets for external dependencies.
- Keep tests and benchmarks as consumers of production targets.
- Use generator expressions only when configure-time logic cannot express the requirement more clearly.
- Do not make a clean rewrite of working build logic without an incremental validation path.

## Deliverable

Report the target graph, public and private usage requirements, configuration matrix, generated or installed interfaces, compatibility impact, and exact validation performed.
