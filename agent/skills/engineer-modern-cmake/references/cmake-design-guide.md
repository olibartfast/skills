# Modern CMake Design Guide

## Target Contract

For every target, record:

| Concern | Decision |
|---|---|
| Kind | Library, interface library, executable, test, benchmark, tool, or imported dependency |
| Sources | Owned implementation and generated sources |
| Public surface | Headers and compile features required by consumers |
| Private surface | Implementation-only definitions, options, includes, and links |
| Conditions | Platform, compiler, feature, or backend gates |
| Lifecycle | Build-tree only, installed, or exported for downstream use |

## Configuration Design

- Give options positive, capability-oriented names and stable defaults.
- Distinguish user choices from detected capabilities.
- Validate at configure time when a choice requires a library, platform, compiler feature, or another option.
- Keep mutually exclusive modes mutually exclusive unless multi-mode operation is intentionally supported and tested.
- Put repeatable configurations in presets without hiding the underlying cache variables.
- Keep toolchain and package-manager selection outside ordinary target logic.

## Target Usage Requirements

- `PRIVATE`: needed only to compile or link the target itself.
- `PUBLIC`: needed by both the target and consumers because it appears in the public contract.
- `INTERFACE`: needed only by consumers, as with header-only libraries or facade targets.

Avoid fixing missing requirements by making everything public. That increases coupling, leaks dependency headers and definitions, and makes installed packages fragile.

## Build and Install Verification

1. Configure from an empty build tree with each supported primary preset or option set.
2. Build with strict warnings where supported.
3. Run the relevant tests and benchmarks.
4. Install into a temporary prefix.
5. Configure a minimal downstream consumer against the installed package when exports are supported.
6. Verify disabled optional components do not leak sources, definitions, or dependency requirements.
7. Inspect configure messages for actionable failures rather than silent fallback.

## Warning Signs

- Global `include_directories`, `link_libraries`, definitions, or compiler flags.
- Consumers compiling only because another target accidentally leaked requirements.
- Options accepted but ignored.
- Backend source files compiled when their backend is disabled.
- Build-tree paths embedded in installed exports.
- Tests reimplementing production source lists instead of linking the production target.
