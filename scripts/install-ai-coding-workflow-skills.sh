#!/usr/bin/env bash
set -euo pipefail

exec npx skills@latest add olibartfast/skills \
  --skill orchestrate-ai-coding-workflows \
  --skill choose-agent-workflow \
  --skill apply-spec-driven-development \
  --skill design-ai-systems \
  --yes \
  "$@"
