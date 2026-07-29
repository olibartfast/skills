# SIMD Review Guide

## Contents

- Profitability screen
- Blocker checklist
- Restructuring patterns
- Google Highway decision
- Verification

## Profitability screen

SIMD is most promising when iterations perform the same operation on contiguous, independent
elements and trip counts are large enough to amortize setup and tails. It is less promising for
pointer chasing, unpredictable early exits, tiny loops, heavy scalar calls, or gather-dominated
kernels.

Estimate the real limiter first. Vectorizing arithmetic may not help a bandwidth-saturated loop.

## Blocker checklist

### Dependencies

- loop-carried recurrences
- one accumulator creating a long dependency chain
- stores that may feed later loads
- order-dependent floating-point reductions

Use independent partial accumulators only when the required numerical semantics permit it.

### Aliasing

The compiler may have to assume input and output pointers overlap. Prefer APIs with explicit
non-overlap contracts or restructure ownership. Use compiler-specific `restrict` only when the
contract is true and documented.

### Control flow

- data-dependent branches
- `break`, `continue`, or early return
- calls that cannot be inlined or vectorized
- exception-producing operations

Predication or masks help when both paths are cheap. They can lose when masked-off work is
expensive or one branch is strongly biased.

### Memory layout

Best: aligned or safely unaligned contiguous loads and stores.

More expensive: regular stride, interleaving, gather, scatter.

Usually worst: linked structures and dependent addresses.

When a loop consumes only a subset of fields, SoA can improve both cache density and vector
access. Do not convert layouts without checking all consumers and conversion cost.

### Types and operations

- mixed element widths can require conversions
- division and transcendental functions may dominate
- small integer arithmetic may have promotion or saturation semantics
- floating-point reassociation changes rounding and exceptional behavior

## Restructuring patterns

1. Hoist invariant work and rare checks outside the hot loop.
2. Replace opaque calls with visible, vectorizable operations when maintainable.
3. Split validation from the trusted inner kernel.
4. Convert branches to select/mask operations only after measuring.
5. Separate main vector loop from a scalar or masked tail.
6. Consider multiple accumulators for reductions and ILP.
7. Align allocation when useful, but keep an unaligned-safe API unless alignment is guaranteed.

## Google Highway decision

Choose Google Highway when:

- portable explicit SIMD across CPU families is required
- the codebase accepts the dependency
- dynamic or static target dispatch fits deployment
- the kernel maps cleanly to Highway operations

Prefer auto-vectorization when the loop can be made simple and compiler output is satisfactory.
Prefer scalar code when data shape or trip count makes SIMD unprofitable. Use raw intrinsics only
for a justified fixed target or a gap in the portable abstraction.

For a Highway implementation, verify:

- target namespace and dispatch conventions
- lane count obtained from the active vector tag
- safe full-vector bounds
- tail strategy supported by the chosen API
- no target-specific instruction assumption leaks into the portable path

Consult the installed Highway version's documentation rather than relying on remembered API
names.

## Verification

Use compiler diagnostics:

```bash
# GCC examples
-O3 -fopt-info-vec-optimized -fopt-info-vec-missed

# Clang examples
-O3 -Rpass=loop-vectorize -Rpass-missed=loop-vectorize \
    -Rpass-analysis=loop-vectorize
```

Then inspect assembly for actual vector loads, operations, and stores. Benchmark scalar and SIMD
versions over:

- zero and tiny lengths
- one-less, exact, and one-more than vector width
- non-multiple lengths
- representative cache-resident and memory-resident sizes
- aligned and permitted unaligned addresses
- randomized and adversarial values

Report wall time, throughput, and relevant counters. Do not call a loop vectorized merely because
the compiler report says it considered vectorization.
