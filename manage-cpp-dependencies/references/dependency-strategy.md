# C++ Dependency Strategy

## Provider Matrix

| Provider | Best fit | Main contract |
|---|---|---|
| System package | Distribution-integrated builds | Discover an installed compatible version |
| Conan | Profile-driven binary/source packages | Consume generated package targets without leaking profile state |
| vcpkg | Manifest and toolchain workflows | Resolve through manifest features and imported targets |
| FetchContent | Small or pinned source dependencies | Pin immutable revisions and control network use |
| Vendored source | Tiny, audited, stable code | Record provenance, license, and update procedure |
| Provided root | Air-gapped or pre-provisioned environments | Validate layout and construct a stable imported target |

## Stable Facade

Expose one project-facing target such as `Deps::Package` regardless of provider. The facade must carry:

- include directories;
- link libraries and system libraries;
- compile definitions and features;
- platform-specific requirements;
- component and version validation.

Consumers should not branch on the selected provider.

## Resolution Policy

Decide and document:

1. whether the provider is explicit or automatically selected;
2. the exact precedence when automatic selection is allowed;
3. whether fallback may access the network;
4. which versions and components are acceptable;
5. how static/shared linkage and runtime files are handled;
6. how the selected provider is surfaced in diagnostics.

Do not let a failed explicit provider silently fall through to another ecosystem.

## Reproducibility Checklist

- Pins and lockfiles identify reviewable artifacts.
- Hashes or immutable revisions protect downloads where supported.
- Clean builds do not depend on undeclared user-global state.
- Offline builds succeed from documented pre-provisioned inputs or fail before network access.
- CI exercises each supported provider rather than only parsing its manifest.
- Documentation matches build options, versions, container images, and export-tool packages.

## Failure Diagnostics

Include the logical dependency name, required capability or version, selected provider, paths or package names checked, offline state, and a concrete remediation command or option. Debug logging should explain resolution decisions without exposing credentials.
