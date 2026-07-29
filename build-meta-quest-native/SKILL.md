---
name: build-meta-quest-native
description: Build, debug, and optimize native C or C++ Meta Quest applications with OpenXR, Android NDK, Vulkan or OpenGL ES, JNI, and Quest platform capabilities. Use when implementing an OpenXR loader or frame loop, extensions, graphics bindings, input, composition layers, lifecycle, permissions, native rendering, performance tooling, or migrating legacy VrApi code.
---

# Build Native Meta Quest Apps

Build from negotiated OpenXR capabilities and Android lifecycle facts, not desktop assumptions.

## Workflow

1. Inspect CMake or ndk-build configuration, NDK and Android API levels, OpenXR loader and
   headers, graphics API, manifest, Java/JNI bridge, target devices, and repository guidance.
2. Read [references/documentation-routing.md](references/documentation-routing.md).
3. Retrieve current OpenXR and Quest feature pages plus exact API or extension references.
4. Trace ownership and lifecycle from Android activity through OpenXR instance, system,
   session, spaces, swapchains, actions, and graphics resources.
5. Enumerate and validate required extensions before enabling feature code.
6. Implement the smallest complete change with explicit error handling and cleanup.
7. Build, install, collect Logcat, validate on-device behavior, and profile frame timing when
   performance matters.

## Guardrails

- Prefer OpenXR for new work; use VrApi or retired Oculus Mobile APIs only for a documented
  legacy constraint.
- Check extension availability and load extension functions through the prescribed mechanism.
- Respect OpenXR session states and Android activity, focus, pause/resume, and surface changes.
- Keep predicted display time, view location, swapchain acquire/wait/release, and frame
  submission ordering correct.
- Match Vulkan or OpenGL ES requirements to the runtime before creating graphics resources.
- Do not leak JNI local references, attach threads indefinitely, or retain invalid activity
  objects.
- Handle partial initialization and teardown safely.
- Measure CPU, GPU, compositor, and thermal behavior on the target headset.

## Deliverable

Provide the runtime and graphics assumptions, extensions, official sources, lifecycle and
ownership model, code/build changes, device logs or tests, and migration constraints.
