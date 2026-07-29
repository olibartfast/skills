---
name: build-meta-quest-unity
description: Build, debug, and optimize Meta Quest applications in Unity using current Meta XR, OpenXR, Interaction SDK, rendering, passthrough, tracking, audio, platform, and deployment guidance. Use when modifying a Unity Quest project, configuring packages or Android builds, implementing XR interactions or mixed reality features, diagnosing device-only failures, or preparing a Unity app for distribution.
---

# Build Meta Quest Unity Apps

Implement against the project's actual Unity, package, and device versions.

## Workflow

1. Inspect the Unity version, render pipeline, package manifest, XR provider, Android settings,
   scenes, target devices, and local repository guidance.
2. Read [references/documentation-routing.md](references/documentation-routing.md).
3. Retrieve the current official pages for the requested feature and exact API reference pages
   for symbols being changed.
4. Check whether the project uses Meta XR SDK, Unity OpenXR, or a legacy integration. Preserve
   the established path unless migration is part of the request.
5. Implement the smallest coherent change, including required project settings, permissions,
   scene objects, lifecycle handling, and fallbacks.
6. Validate in the editor where meaningful, produce an Android build, and test on the target
   Quest device when available.
7. Report version assumptions, files and settings changed, device verification, and remaining
   platform risks.

## Guardrails

- Do not mix APIs from incompatible Meta XR, Unity, or OpenXR versions.
- Do not introduce deprecated OVR components for new work when a supported replacement exists.
- Keep capability checks and permission handling explicit.
- Preserve stereo rendering, lifecycle, pause/resume, recenter, and focus behavior.
- Avoid per-frame allocation, blocking I/O, and unnecessary scene searches on hot paths.
- Treat editor simulation as complementary to headset testing.
- Verify Android manifest and Gradle changes in the generated build rather than assuming they
  merged correctly.
- Measure frame timing before claiming a performance improvement.

## Deliverable

Provide the selected integration path, official sources, implementation changes, required Unity
and Android settings, validation commands or steps, and compatibility notes.
