#!/usr/bin/env bash
set -euo pipefail

exec npx skills@latest add olibartfast/skills \
  --skill diagnose-cpu-performance \
  --skill review-cpp-simd \
  --skill author-cpu-optimization-lab \
  --yes \
  "$@"
