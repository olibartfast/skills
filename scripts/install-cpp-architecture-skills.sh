#!/usr/bin/env bash
set -euo pipefail

exec npx skills@latest add olibartfast/skills \
  --skill modernize-cpp-design \
  --skill modernize-cpp-boundaries \
  --skill compose-cpp-components \
  --skill engineer-cpp-dataflows \
  --skill model-cpp-domain-services \
  --skill harden-cpp-services \
  --yes \
  "$@"
