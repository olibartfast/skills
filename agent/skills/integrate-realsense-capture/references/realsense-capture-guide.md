# RealSense Capture Guide

Concrete patterns for adding an Intel RealSense color + aligned-depth source to a C++17/20/23 application.

## 1. Host inspection

```bash
lsusb | grep -i realsense                 # 8086:0b07 is a D435
for f in /sys/class/video4linux/video*/name; do
  printf '%s: ' "$(basename "$(dirname "$f")")"; cat "$f"
done
id                                        # group membership
ls -l /dev/bus/usb/*/* | grep -i -A0 ""   # usually root:root
ls /etc/udev/rules.d | grep -i realsense
```

A UVC node being readable does not mean the RealSense USB device is writable. librealsense opens the USB device, not `/dev/video*`, so the udev rules matter independently of OpenCV access.

Build dependencies on Debian/Ubuntu:

```bash
sudo apt-get install libusb-1.0-0-dev libudev-dev
```

## 2. Optional CMake integration

```cmake
option(USE_REALSENSE "Build with Intel RealSense camera capture support" OFF)

if(USE_REALSENSE)
  find_package(realsense2 QUIET)
  if(NOT realsense2_FOUND)
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(BUILD_GRAPHICAL_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(BUILD_TOOLS OFF CACHE BOOL "" FORCE)
    set(BUILD_PYTHON_BINDINGS OFF CACHE BOOL "" FORCE)
    set(BUILD_UNIT_TESTS OFF CACHE BOOL "" FORCE)
    set(BUILD_WITH_TM2 OFF CACHE BOOL "" FORCE)
    set(BUILD_WITH_OPENMP OFF CACHE BOOL "" FORCE)
    set(BUILD_WITH_STREAM_SETS OFF CACHE BOOL "" FORCE)
    FetchContent_Declare(
      librealsense
      GIT_REPOSITORY https://github.com/IntelRealSense/librealsense.git
      GIT_TAG v2.59.1
      GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(librealsense)
  endif()

  if(TARGET realsense2::realsense2)
    set(REALSENSE_LIBRARIES realsense2::realsense2)
  elseif(TARGET realsense2)
    set(REALSENSE_LIBRARIES realsense2)
  elseif(realsense2_LIBRARY)
    set(REALSENSE_LIBRARIES ${realsense2_LIBRARY})
  endif()

  target_compile_definitions(app PRIVATE USE_REALSENSE)
  target_link_libraries(app PRIVATE ${REALSENSE_LIBRARIES})
endif()
```

Put `realsense_source.cpp` in the source list only under `USE_REALSENSE`. Keep the interface and the capture writer in always-built files.

**C++20 caveat.** librealsense v2.59.1 contains a constructor declaration (`single_consumer_frame_queue< T >(unsigned)`) that GCC 13 rejects under C++20 but accepts under C++17. If the parent project is C++20, save and restore the standard around the subproject instead of lowering the whole project:

```cmake
set(DA3_CXX_STANDARD "${CMAKE_CXX_STANDARD}")
set(CMAKE_CXX_STANDARD 17)
FetchContent_MakeAvailable(librealsense)
set(CMAKE_CXX_STANDARD "${DA3_CXX_STANDARD}")
```

Clang 18 accepts the declaration under C++20, so the failure is compiler-specific. Verify the actual compile line (`-std=gnu++17` for the SDK) rather than assuming.

## 3. Source interface

```cpp
struct Intrinsics { float fx, fy, cx, cy; int width, height; };

struct Frame {
  cv::Mat color_bgr;   // CV_8UC3
  cv::Mat depth_mm;    // CV_16UC1, aligned to color, empty if unavailable
  Intrinsics intrinsics;
  std::uint64_t timestamp_ms{0};
};

class Source {
public:
  virtual ~Source() = default;
  virtual std::string device_name() const = 0;
  virtual bool next(Frame& frame) = 0;   // blocking; false when the stream ends
};
```

The interface contains no vendor types. Tests implement it with synthetic matrices.

## 4. Pipeline and alignment

```cpp
#include <librealsense2/rs.hpp>

rs2::pipeline pipe;
rs2::config cfg;
cfg.enable_stream(RS2_STREAM_COLOR, 0, width, height, RS2_FORMAT_BGR8, fps);
cfg.enable_stream(RS2_STREAM_DEPTH, 0, 0, 0, RS2_FORMAT_Z16, fps); // 0x0 = device default

rs2::pipeline_profile profile = pipe.start(cfg);
const rs2::video_stream_profile color_stream =
    profile.get_stream(RS2_STREAM_COLOR).as<rs2::video_stream_profile>();
const rs2_intrinsics intr = color_stream.get_intrinsics();

rs2::align align_to_color(RS2_STREAM_COLOR);
rs2::frameset aligned = align_to_color.process(pipe.wait_for_frames());
rs2::video_frame color = aligned.get_color_frame();
rs2::depth_frame depth = aligned.get_depth_frame();
```

Wrap `pipe.start` and `wait_for_frames` in `try`/`catch (const rs2::error&)`. librealsense throws for missing devices, unsupported profiles, busy devices, and permission failures.

## 4b. Factory intrinsics versus chessboard calibration

D400-series cameras are factory-calibrated. The color stream profile carries `fx`, `fy`, `ppx`, `ppy`, the distortion model, and coefficients, and the device stores depth-to-color extrinsics used by `rs2::align`. Use those values; they are per-mode, so changing resolution changes the numbers.

A chessboard re-calibration is a deliberate exception, not a setup step:

- use it to verify a suspicious camera, or to replace color calibration after a lens, focus, or housing change;
- capture 20–30 views at varied poses covering the frame corners, at the exact resolution used for inference;
- run `cv::calibrateCamera`, check the RMS reprojection error (roughly below 0.5 px), and compare with the factory values;
- keep the factory calibration when the two agree.

Do not chessboard-calibrate the depth sensor. Depth is calibrated on-chip; use Intel's on-chip calibration when depth accuracy is in question. For point clouds, use `rs2_deproject_pixel_to_point` with the profile intrinsics instead of assuming a pinhole model with a single focal length.

## 5. Depth conversion

```cpp
const float mm_per_unit = depth.get_units() * 1000.0F;  // get_units() is metres/unit
const cv::Mat view(depth.get_height(), depth.get_width(), CV_16UC1,
                   const_cast<void*>(depth.get_data()), depth.get_stride_in_bytes());
cv::Mat depth_mm(depth.get_height(), depth.get_width(), CV_16UC1);
for (int y = 0; y < view.rows; ++y) {
  const auto* src = view.ptr<std::uint16_t>(y);
  auto* dst = depth_mm.ptr<std::uint16_t>(y);
  for (int x = 0; x < view.cols; ++x) {
    dst[x] = cv::saturate_cast<std::uint16_t>(static_cast<float>(src[x]) * mm_per_unit);
  }
}
```

Zero means "no measurement". Do not confuse it with a valid zero distance. Always construct `cv::Mat` views with the reported stride and clone anything that outlives the frameset.

## 6. Capture layout and metadata

```
capture/
  color/000.png …        lossless BGR
  depth/000.png …        16-bit millimetres, aligned to color
  intrinsics.txt         fx fy cx cy per frame
  capture.txt            device, requested profile, counts, timestamps, units
```

Reasons for the split:

- An image collector that globs `*.png` must not treat depth maps as input views.
- Depth and color keep the same index, which makes later comparison trivial.
- Intrinsics stay in the task's existing format instead of a new schema.
- `capture.txt` makes the recording self-describing when the device is unplugged.

Convert the focal length for metric models only from the device values (`mean(fx, fy)`), and let an explicit user value win.

## 7. Permissions

```bash
sudo cp <librealsense>/config/99-realsense-libusb.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
# replug the camera
```

The rules file ships with the SDK source. With a source build it is under `<build>/_deps/librealsense-src/config/`. Distribution packages usually install it automatically.

A permission failure commonly surfaces as "No device connected" or a `rs2::error` mentioning `LIBUSB_ERROR_ACCESS`. Append the rules remedy to the start-up error rather than making the user guess.

## 8. Hardware-free tests

Implement a fake `Source` that yields deterministic `cv::Mat` frames and intrinsics. Test:

- exact color and depth file counts and names;
- 16-bit depth encoding and the expected millimetre value;
- intrinsics formatting and the focal derivation;
- one color-only capture path;
- early stream end, invalid frame count, non-positive fps, and depth/color size mismatch;
- unsupported color formats (grayscale, BGRA) if the writer converts them.

These tests run in CI without a camera or model. The real device remains a separate, dated validation step.

## 9. Hardware validation checklist

| Check | Pass condition |
|---|---|
| Device visible | `lsusb` shows the expected PID and the app prints the device name |
| Stream profile | Requested size and fps are accepted, or the failure is actionable |
| Alignment | Aligned depth dimensions equal color dimensions |
| Depth | 16-bit PNG, non-zero over the scene, plausible values in metres |
| Intrinsics | Positive `fx/fy`, principal point inside the image, stable across frames |
| Focal | Defaults to `mean(fx, fy)`; explicit user value wins |
| Layout | `color/` contains only color frames; `depth/` contains only depth |
| Retention | Explicit capture directory is kept; default directory is discoverable |
| Failure modes | No-device and permission-denied messages name the remedy |

## 10. Common pitfalls

- **Mixed folders:** depth PNGs land in the input glob and become views. Use sibling directories.
- **Misaligned maps:** forgetting `rs2::align`, or assuming the depth resolution equals color.
- **Unit errors:** treating raw Z16 as metres. Read `get_units()`.
- **Stride bugs:** wrapping `get_data()` without `get_stride_in_bytes()`.
- **Per-pixel `get_distance`:** orders of magnitude slower than a buffer pass.
- **Fabricated focal lengths:** hardcoding a datasheet value instead of reading the profile.
- **Broken CI:** making librealsense unconditional. Gate it and keep a hardware-free test path.
- **Root-only workflows:** documenting `sudo ./app` instead of installing udev rules.
- **USB 2 surprises:** a resolution that works on USB 3 may be rejected or throttled on USB 2.
- **Dropped frames:** `wait_for_frames` can skip frames; use timestamps, not an assumed fixed interval.
