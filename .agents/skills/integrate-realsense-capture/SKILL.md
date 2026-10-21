---
name: integrate-realsense-capture
description: Capture calibrated color and aligned depth from Intel RealSense cameras in C++ with librealsense, including optional-build wiring, udev permissions, frame layout, intrinsics handling, and hardware-free tests. Use when adding a D435, D405, or L515 source to a C++ application, capturing depth as a metric reference, or deciding between librealsense and OpenCV V4L2.
---

# Integrate RealSense Capture

Treat the camera as a source adapter, not as part of the inference or product core. Capture calibrated data once, then feed the existing pipeline unchanged.

## Workflow

1. Establish what the application needs: color only, color plus depth, or depth aligned to color with exact intrinsics. If depth becomes a measurement or validation reference, plan for alignment and calibration from the start.
2. Inspect the host before writing code: `lsusb`, `/sys/class/video4linux/video*/name`, group membership, udev rules, and whether `libusb-1.0-0-dev` and `libudev-dev` are installed.
3. Choose the access path. Prefer librealsense when alignment, intrinsics, depth scale, or device controls matter. OpenCV V4L2 is acceptable for a color-only convenience stream but cannot sanely provide calibration.
4. Gate the dependency behind an explicit build option (`USE_REALSENSE`, default `OFF`). Find a system package first, then build a pinned release from source. Keep the default build, CI, and containers free of the SDK.
5. Put the SDK behind a narrow `Source` interface returning one frame at a time. Keep capture, file layout, and metadata in code that does not include the vendor header.
6. Configure color and depth streams explicitly, align depth to color, and read intrinsics from the active color stream profile.
7. Convert raw depth to a documented physical unit and store it without loss. Millimetre `uint16` PNG is a practical default; record the unit in metadata.
8. Write intrinsics in the same format the downstream task already consumes, and auto-fill focal length only when the user did not provide one.
9. Test the capture loop with a synthetic source. Keep hardware checks as an explicit, dated validation step.
10. Run the capture on the device, inspect color and depth dimensions, and record the exact device profile and permissions used.

Read [references/realsense-capture-guide.md](references/realsense-capture-guide.md) for the CMake block, pipeline code, depth conversion, layout, and validation checklist.

## Rules

- Never fabricate intrinsics or focal lengths. Read `fx`, `fy`, `ppx`, and `ppy` from the active profile, or require the user to provide calibration. Prefer the factory per-profile values; chessboard re-calibration is only for verification or a deliberate replacement after hardware changes.
- Align depth to color (`rs2::align(RS2_STREAM_COLOR)`) before treating the maps as co-registered. Verify the aligned depth size matches the color size.
- Convert depth from device units explicitly: `millimetres = raw * depth_frame.get_units() * 1000`. Do not assume `0.001` without reading `get_units()`.
- Never call `get_distance(x, y)` per pixel in a loop. Process the raw depth buffer and convert in one pass.
- Keep depth files out of input image globs. Use sibling `color/` and `depth/` directories rather than one mixed folder.
- Use lossless color frames for capture. JPEG compression hides alignment and depth-edge errors.
- Make udev rules a documented one-time host step. Do not make the build require root, and do not silently run `sudo` from application code.
- Fail with the missing capability and the remedy: a build without the SDK explains the configure flag; a permission failure names the udev rules and USB node.
- Pin the SDK tag and disable examples, tools, tests, and language bindings in source builds. A full default build pulls in unrelated targets and slows every configure.
- Do not make the camera a hard dependency of a library that should link and test without it. Use a compile definition on the owning target and a separate translation unit.
- On USB 2 links, expect lower resolution or frame rate. Verify the negotiated profile instead of assuming USB 3.
- Verify the USB link before debugging capture code. D400 devices on USB 2 can enumerate and expose valid profiles yet fail to stream with truncated UVC frames. Require a USB 3 port and cable; a single working OpenCV frame does not prove the link is healthy.

## Deliverable

Report the capture mode, SDK access path and pinned version, device and stream profile, alignment and depth-unit handling, intrinsics source, capture directory layout, retention policy, build-option isolation, hardware-free test coverage, and the dated hardware validation result including udev status.
