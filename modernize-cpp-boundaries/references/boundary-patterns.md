# Boundary and Migration Patterns

Adapted from [Modern C++ Design Patterns Beyond GoF](https://olibartfast.ninja/blog/modern-cpp-design-patterns-beyond-gof.html).

## Anti-Corruption Layer

Use an anti-corruption layer when an external system's concepts would distort the internal domain. Translate:

- handles into RAII owners;
- foreign records into domain values;
- status codes and global error state into the project error model;
- callbacks into scoped subscriptions or events;
- units, time bases, encodings, identifiers, and coordinate systems;
- vendor threading requirements into explicit execution policies.

Keep the layer narrow. It should protect the domain, not become a second application.

## Adapter Boundary

Use a direct adapter when models are already compatible and only an interface or call convention differs. Prefer composition around the foreign object. Document whether the adapter owns, borrows, pins, or copies each resource.

## PImpl Boundary

Use PImpl when a public C++ type must hide vendor headers, macros, volatile implementation types, or rebuild-heavy dependencies, or when a controlled ABI surface is required.

- Keep `Impl` construction and destruction in the implementation file.
- Declare the facade destructor and any move operations out of line when complete-type rules require it.
- Decide whether copying is prohibited, deep, shared, or clone-based.
- Treat allocation and indirection as costs to justify, especially for small or hot objects.
- Do not use PImpl as a substitute for a coherent public contract.

When the hidden resource requires a vendor-specific destroy function, device context, executor, or thread, encode that requirement in the implementation owner or custom deleter.

## Strangler Migration

1. Characterize behavior and operational constraints.
2. Introduce a stable routing seam.
3. Choose one end-to-end capability.
4. Implement and observe the new path.
5. Shadow or canary traffic where side effects permit.
6. Compare correctness, latency, failures, and resource use.
7. Shift traffic gradually with a rollback switch.
8. Remove the old path and compatibility code only after stabilization.

## Boundary Test Matrix

| Area | Test |
|---|---|
| Construction | Invalid config, partial initialization, repeated creation |
| Destruction | Normal, failure, callback in flight, wrong thread |
| PImpl/ABI | Incomplete type, move/destruction, symbol visibility, version skew |
| Buffers | Empty, maximum, undersized, misaligned, truncated |
| Errors | Every documented status, unknown status, diagnostic preservation |
| Concurrency | Concurrent calls, reentrancy, cancellation, teardown race |
| Versions | Missing symbol, older/newer API, optional capability |
| Migration | Old/new equivalence, routing failure, rollback |

## Warning Signs

- Vendor headers included throughout domain code.
- Raw handles stored without a destruction protocol.
- External error integers returned from internal APIs.
- “Temporary” compatibility types becoming the canonical model.
- A rewrite plan with no routing seam, observability, or rollback.
