#!/usr/bin/env bash
set -euo pipefail

exec npx skills@latest add olibartfast/skills \
  --skill integrate-realsense-capture \
  --yes \
  "$@"
