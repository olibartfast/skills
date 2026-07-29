---
name: build-meta-quest-webxr
description: Build, debug, and optimize immersive web experiences for Meta Quest Browser using WebXR, WebGL, WebXR media layers, or Meta Immersive Web SDK. Use when implementing XR session setup, reference spaces, input, hands, interactions, ECS systems, rendering, spatial audio or video, browser compatibility, remote debugging, graceful non-XR fallback, or web deployment.
---

# Build Meta Quest WebXR Apps

Progressively enhance a secure web application into an immersive Quest experience.

## Workflow

1. Inspect the framework, package versions, bundler, rendering stack, Immersive Web SDK use,
   browser targets, hosting security, and local repository guidance.
2. Decide whether to use browser WebXR directly, an existing engine abstraction, or Meta
   Immersive Web SDK.
3. Read [references/documentation-routing.md](references/documentation-routing.md).
4. Retrieve current Browser and SDK pages plus the relevant web-standard specifications.
5. Implement feature detection, session and reference-space lifecycle, rendering, input,
   interaction, media, and a usable non-XR fallback.
6. Run automated web checks, test in a desktop browser where applicable, remotely debug Quest
   Browser, and verify on the target headset.
7. Report supported paths, sources, browser assumptions, performance results, and fallbacks.

## Guardrails

- Require a secure context and user activation where the WebXR API requires them.
- Feature-detect sessions, reference spaces, input capabilities, layers, and optional features.
- End sessions and release listeners, graphics resources, media, and ECS entities cleanly.
- Avoid per-frame DOM work, allocation, shader compilation, and synchronous network activity.
- Keep world scale, reach, locomotion, comfort, safety, and input modality differences explicit.
- Preserve keyboard, mouse, touch, and flat-screen behavior where the product supports them.
- Do not treat desktop emulation as headset validation.
- Re-check Quest Browser codecs, media-layer support, and submission guidance at task time.

## Deliverable

Provide the selected WebXR stack, official sources, capability matrix, implementation changes,
fallback behavior, remote-debugging steps, and headset validation.
