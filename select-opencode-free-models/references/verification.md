# Verify Free Models

## Read the catalog

```sh
# Runtime catalog for the current account (all providers)
opencode models

# Filter for free models across providers
opencode models | grep -E 'free|pickle|:free$'

# Interactive picker
opencode
# then /models
```

**Documentation by provider:**
- OpenCode Console: <https://opencode.ai/docs/console/models/>
- OpenRouter free: <https://openrouter.ai/models?max_price=0>
- NVIDIA: <https://build.nvidia.com/explore/discover>

## Check LMSYS Chatbot Arena (open-source filter)

```sh
# Open the Arena leaderboard filtered to open-source models
# Use this to cross-reference quality rankings for models in your catalog
open https://arena.ai/leaderboard/agent?license=open-source
```

Record the Arena rank and date for each candidate model alongside the probe
results. This provides an independent quality signal when multiple models share
the same privacy class and reachability.

## Probe one model

```sh
# OpenCode Console
opencode run --archived --model opencode/deepseek-v4.1-flash-free \
  "Reply with exactly: OK"

# OpenRouter
opencode run --archived --model openrouter/meta-llama/llama-3.1-8b-instruct:free \
  "Reply with exactly: OK"

# NVIDIA
opencode run --archived --model nvidia/nemotron-3-ultra \
  "Reply with exactly: OK"
```

The `--archived` flag keeps the probe out of normal session history. Use the
exact model ID and variant you intend to configure.

## Probe a set

```sh
chmod +x scripts/probe-free-models.sh
./scripts/probe-free-models.sh
./scripts/probe-free-models.sh deepseek-v4.1-flash-free inkling-2-small-free
```

The script prints `MODEL`, `STATUS`, and `DETAIL` columns. It does not modify
configuration.

## Interpret failures

| Output contains | Status | Next step |
| --- | --- | --- |
| `OK` and exit 0 | reachable | record the date |
| `Model unavailable` | unavailable | remove or replace |
| `not available in your country` | geo-blocked | replace; retry is useless |
| `429`, `quota`, `rate` | throttled | move role or lower fan-out |
| timeout | stalled | retry once, then replace |
| `unauthorized`, `auth` | credential problem | reconnect the provider |

## Record template

| Field | Example |
| --- | --- |
| Probe date | 2026-11-14 |
| Provider | `opencode` / `openrouter` / `nvidia` |
| Model | `opencode/deepseek-v4.1-flash-free` |
| Variant | `max` |
| Role | architect |
| Privacy class | zero-retention |
| Region result | reachable |
| Arena rank (open-source) | top-5 (2026-11-14) |
| Fallback | `opencode/glm-5.3-flash-free#high` |

Keep the record beside the agent configuration so a later failure has context.

## Verify an agent configuration

Read back the loaded agent and model:

```sh
opencode api get /api/agent
```

Confirm the ID, `model.providerID`, `model.id`, and `mode` for each role.

## Re-verification triggers

- a new long or expensive run;
- any model or provider error;
- a documentation change or deprecation notice;
- a free model being withdrawn;
- a change to the configured variant;
- significant shift in LMSYS Arena open-source rankings for the model family.
