# Pattern Selection

Adapted from [Modern C++ Design Patterns Beyond GoF](https://olibartfast.ninja/blog/modern-cpp-design-patterns-beyond-gof.html). Use this reference as a decision aid, not as a mandatory catalog.

## Decision Matrix

| Pressure | Prefer | Avoid by default | Key caveat |
|---|---|---|---|
| Closed set of data alternatives | `std::variant` + `std::visit` | Invasive Visitor hierarchy | Adding a type requires recompiling visitors |
| Open runtime set of implementations | Virtual interface or type erasure | Closed variant | Define ownership and ABI |
| One replaceable operation | Lambda or function object | Strategy class hierarchy | Capture lifetime must be safe |
| Copyable runtime callable | `std::function` | Owning raw callback pointer | May allocate; inspect hot paths |
| Move-only runtime callable | `std::move_only_function` (C++23) or custom erasure | Forced shared ownership | Verify library availability |
| Compile-time behavioral requirement | Concept + template | Marker base class | Can increase build time/code size |
| Compile-time configuration | Policy-based design | Runtime branches | Avoid combinatorial instantiation |
| Resource ownership | RAII value type | Manual cleanup protocol | Deleter and destruction context matter |
| Optional result | `std::optional` | Sentinel value | Absence has no diagnostic |
| Value or error | Project result type or `std::expected` (C++23) | Scattered status/out parameters | Preserve error context |

## Review Questions

1. Is the type set genuinely closed?
2. Must downstream users add implementations without rebuilding?
3. Is ABI stability required?
4. Does state need copy or move semantics?
5. Is dispatch cost measured and material?
6. Can template instantiation cost be tolerated?
7. Who owns the object, callback target, or captured state?
8. Does the proposed abstraction make domain intent clearer?

## Common Failure Modes

- Converting an extensible plugin model into a closed variant.
- Capturing references in a callable stored longer than its source object.
- Using `shared_ptr` to avoid deciding ownership.
- Replacing a small virtual interface with complex custom type erasure.
- Using concepts as documentation while accepting semantically invalid types.
- Claiming static dispatch is faster without measuring the end-to-end workload.
