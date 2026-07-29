---
name: manage-cpp-dependencies
description: Design, review, and repair reproducible C++ dependency resolution across system packages, Conan, vcpkg, FetchContent, vendored sources, and pre-provided roots. Use when adding or upgrading a dependency, supporting multiple package providers, enforcing offline builds, creating imported-target facades, diagnosing inconsistent versions, or synchronizing dependency declarations across CMake, manifests, containers, CI, and documentation.
---

# Manage C++ Dependencies

Separate what the project needs from how each environment provides it. Make versions, fallback, network access, and consumer targets explicit.

## Workflow

1. Inventory the dependency's required version, components, linkage, compile definitions, platform constraints, license, and transitive requirements.
2. Inspect every source of dependency truth: build files, manifests, lockfiles, containers, CI, export tooling, and user documentation.
3. Read [references/dependency-strategy.md](references/dependency-strategy.md).
4. Define one stable project-facing target contract.
5. Implement or repair each supported provider behind that contract.
6. Define provider precedence, fallback, offline behavior, diagnostics, and failure policy.
7. Update version and option documentation in the same change.
8. Validate clean resolution for each supported provider and confirm consumers link only to the stable target.

## Dependency Rules

- Prefer namespaced imported or interface targets over raw library paths and global flags.
- Keep provider-specific variables and package names out of consuming targets.
- Pin downloaded source and binary coordinates to immutable or reviewable versions.
- Treat offline mode as a hard network prohibition, not a best-effort hint.
- Fail with the missing capability, attempted provider, and remediation steps.
- Do not silently combine incompatible providers for the same package.
- Preserve transitive usage requirements without leaking unrelated components.
- Keep package-manager toolchains, generated files, and build directories out of source-controlled interfaces unless intentionally required.
- Reconcile declared versions with containers, CI, exports, and documentation before completion.

## Deliverable

Report the dependency contract, supported providers, precedence and fallback, version sources, offline behavior, diagnostics, compatibility impact, and provider matrix validated.
