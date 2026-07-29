# Composition Patterns

Adapted from [Modern C++ Design Patterns Beyond GoF](https://olibartfast.ninja/blog/modern-cpp-design-patterns-beyond-gof.html).

## Mechanism Matrix

| Need | Mechanism | Contract |
|---|---|---|
| Required stable dependency | Constructor injection | Object cannot exist without it |
| Optional collaborator | Explicit optional/reference wrapper or null object | Absence behavior is defined |
| Deferred creation | Injected factory | Caller controls when creation occurs |
| Startup wiring | Composition root | Owns graph construction and teardown |
| Select implementation by configuration | Factory registry | Keys, duplicates, and unknown values are defined |
| Select one implementation at build time | Conditional composition root | Options, sources, links, and definitions stay consistent |
| Third-party runtime extension | Plugin boundary | ABI, version, lifetime, and unload policy are defined |
| Cross-cutting lookup during migration | Constrained locator | Scope, initialization, and replacement are controlled |

## Ownership Checklist

- Assign one owner to each long-lived component.
- Ensure owners outlive injected references.
- Destroy dependents before dependencies.
- Keep threads, callbacks, and handles inside an owner with deterministic shutdown.
- Avoid cycles of shared ownership.
- Make factories return ownership that matches the created lifetime.

## Registry Checklist

- Define stable identifiers and capability discovery.
- Reject or resolve duplicate keys deterministically.
- Return typed errors for missing or incompatible implementations.
- Separate registration from lookup after startup when possible.
- Freeze or synchronize mutation before concurrent access.
- Test registration order independence.

## Backend Selection Checklist

- Is selection compile-time, startup-time, or runtime, and why?
- Can multiple implementations coexist safely in one binary?
- Does each backend advertise or validate supported inputs and capabilities?
- Are backend-specific headers and dependencies contained?
- Do invalid or missing selections fail before partially constructing the object graph?
- Can tests inject a fake backend without loading a vendor runtime?
- Are build options, factory behavior, documentation, and test matrices synchronized?

## Plugin Checklist

- Prefer a C-compatible entry point at binary boundaries.
- Exchange opaque handles or versioned plain structures.
- Define allocator ownership across the boundary.
- Negotiate interface and feature versions.
- Keep a module loaded while any object, function pointer, or callback from it remains live.
- Avoid unloading unless required; safe unload is a lifecycle feature, not a free operation.

## Removing a Service Locator

1. Find every lookup and classify the dependency.
2. Add constructor parameters at leaf consumers.
3. Push wiring upward one layer at a time.
4. Keep a temporary adapter at the composition root.
5. Remove global mutation and test overrides.
6. Delete the locator after the final lookup disappears.
