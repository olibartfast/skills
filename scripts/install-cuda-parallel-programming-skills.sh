#!/usr/bin/env bash
set -euo pipefail

exec npx skills@latest add olibartfast/skills \
  --skill select-cuda-parallel-patterns \
  --skill implement-cuda-data-primitives \
  --skill optimize-cuda-memory-locality \
  --skill coordinate-cuda-thread-groups \
  --skill pipeline-cuda-streams \
  --skill profile-optimize-cuda \
  --yes \
  "$@"
