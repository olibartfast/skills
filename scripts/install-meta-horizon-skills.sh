#!/usr/bin/env bash
set -euo pipefail

exec npx skills@latest add olibartfast/skills \
  --skill research-meta-horizon-docs \
  --skill build-meta-quest-unity \
  --skill build-meta-quest-unreal \
  --skill build-meta-spatial-sdk-apps \
  --skill adapt-android-apps-horizon \
  --skill build-meta-quest-native \
  --skill build-meta-quest-webxr \
  --yes \
  "$@"
