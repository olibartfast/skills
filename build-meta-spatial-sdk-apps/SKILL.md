---
name: build-meta-spatial-sdk-apps
description: Build, extend, debug, and optimize Meta Spatial SDK applications and hybrid 2D/spatial Android apps for Meta Quest. Use when working with Kotlin, Jetpack Compose, Gradle, spatial entities and components, panels, scenes, input, lifecycle, permissions, platform services, or converting an existing Android app into an immersive Horizon OS experience.
---

# Build Meta Spatial SDK Apps

Treat Spatial SDK as an Android framework with an XR lifecycle, spatial scene, and device limits.

## Workflow

1. Inspect Kotlin, Android Gradle Plugin, Compose, Spatial SDK, min/target SDK, application
   manifest, activity lifecycle, target devices, and repository guidance.
2. Decide whether the app is spatial-only, 2D with optional spatial mode, or an existing 2D app
   being extended.
3. Read [references/documentation-routing.md](references/documentation-routing.md).
4. Retrieve the current setup and feature pages plus the API reference for the project's exact
   Spatial SDK release.
5. Model entity ownership, component state, panel or scene lifecycle, input, permissions, and
   transitions between 2D and immersive presentation.
6. Implement the smallest coherent change and keep ordinary Android domain logic independent
   from spatial presentation where practical.
7. Build with Gradle, run focused tests, install on the target headset, and verify lifecycle and
   interaction behavior.

## Guardrails

- Do not copy APIs from a different Spatial SDK release.
- Keep entity creation, attachment, disposal, and lifecycle ownership explicit.
- Preserve Android configuration changes needed by existing phone, tablet, or companion modes.
- Handle capability absence, permission denial, activity recreation, pause/resume, and teardown.
- Keep Compose state and spatial engine state synchronized without creating feedback loops.
- Avoid unbounded per-frame entity creation, allocation, or main-thread work.
- Verify depth, scale, reach, comfort, safety, and input across supported controllers and hands.
- Test hybrid transitions on hardware.

## Deliverable

Provide the app mode, version context, official sources, Gradle/manifest/code changes, spatial
ownership model, validation results, and remaining device-specific risks.
