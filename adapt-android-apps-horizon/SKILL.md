---
name: adapt-android-apps-horizon
description: Adapt, debug, and distribute conventional 2D Android applications for Meta Horizon OS and Meta Quest. Use when checking Android compatibility, responsive window behavior, input, media, authentication, camera, billing, runtime Horizon detection, Android Studio tooling, companion apps, or deciding whether an app should remain 2D or add immersive features through Spatial SDK.
---

# Adapt Android Apps for Meta Horizon OS

Preserve ordinary Android behavior while making headset-specific differences explicit.

## Workflow

1. Inspect the Android Gradle Plugin, Kotlin or Java versions, min/target SDK, manifest, UI
   toolkit, input model, media stack, authentication, billing, and supported form factors.
2. Establish whether the goal is compatibility, headset-specific 2D enhancement, a companion
   app, or immersive expansion.
3. Read [references/documentation-routing.md](references/documentation-routing.md).
4. Retrieve current compatibility and feature pages plus policy or distribution guidance that
   affects the task.
5. Implement adaptive UI, input, runtime detection, capability checks, permissions, media, or
   platform integration without making Horizon behavior the default on other devices.
6. Build and test ordinary Android variants, then install and verify the Horizon variant on a
   supported Quest device.
7. Recommend Spatial SDK only when the requested experience genuinely requires immersive or
   spatial presentation.

## Guardrails

- Do not assume phone hardware, touch input, portrait orientation, or Google Play services.
- Do not identify Horizon OS from brittle device-name or manufacturer string checks when an
  official support mechanism exists.
- Keep headset-specific resources and code paths isolated and capability-gated.
- Handle mouse, controller, keyboard, focus, back navigation, window resizing, and text input.
- Verify authentication redirects, billing provider behavior, DRM, camera, codecs, and storage
  on the target device.
- Preserve accessibility and non-headset form factors.
- Re-check current design requirements and distribution policies before release work.

## Deliverable

Provide the compatibility target, official sources, platform differences, code/configuration
changes, cross-device test matrix, and any rationale for adding Spatial SDK.
