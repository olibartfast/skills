---
name: build-meta-quest-unreal
description: Build, debug, and optimize Meta Quest applications in Unreal Engine using current Meta XR, OpenXR, Blueprint, C++, rendering, interaction, passthrough, platform, and Android deployment guidance. Use when modifying an Unreal Quest project, configuring plugins or packaging, implementing XR gameplay or mixed reality features, diagnosing headset failures, or preparing an Unreal app for distribution.
---

# Build Meta Quest Unreal Apps

Align every change with the project's Unreal, plugin, and Android toolchain versions.

## Workflow

1. Inspect the engine version, `.uproject`, enabled plugins, modules, rendering settings,
   Android configuration, target devices, and local repository guidance.
2. Read [references/documentation-routing.md](references/documentation-routing.md).
3. Retrieve current official feature pages and exact API references before choosing Blueprint
   or C++ symbols.
4. Identify whether the project uses Meta XR, OpenXR, or legacy Oculus integrations and avoid
   crossing those boundaries accidentally.
5. Implement the smallest complete change in Blueprint, C++, configuration, or a combination.
6. Compile affected modules, package for Android, inspect packaging logs, and test on the target
   headset when available.
7. Report sources, version assumptions, settings, code changes, and device results.

## Guardrails

- Prefer supported Meta XR or OpenXR paths over retired Oculus APIs for new work.
- Keep plugin dependencies and module declarations explicit.
- Validate Blueprint references after renames or C++ signature changes.
- Handle permissions, session lifecycle, focus, pause/resume, and capability absence.
- Avoid heavy Blueprint ticks, synchronous asset loads, and avoidable render-thread stalls.
- Check Android manifests, Gradle additions, and packaging output after configuration changes.
- Verify rendering and interaction on hardware; desktop preview is not sufficient evidence.
- Measure CPU and GPU frame costs before making performance claims.

## Deliverable

Provide the integration path, official sources, Blueprint/C++ and configuration changes,
packaging or device validation, and compatibility risks.
