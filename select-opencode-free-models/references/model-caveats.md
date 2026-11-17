# OpenCode Free Model Caveats

Snapshot: 2026-11-14. Providers: `opencode` (OpenCode Console free tier),
`openrouter` (OpenRouter free tier), `nvidia` (NVIDIA free tier).
Sources: Console model documentation, OpenRouter model cards, NVIDIA build docs,
the live runtime catalog, and per-model reachability probes. Free availability
is time-limited; re-run the probes before relying on this table.

## Observed snapshot — OpenCode Console

| Model ID | Variants | Privacy class | Probe | Arena rank (open-source) |
| --- | --- | --- | --- | --- |
| `deepseek-v4.1-flash-free` | low, high, max | zero-retention, no training | reachable | top-5 |
| `glm-5.3-flash-free` | low, high, max | zero-retention, no training | reachable | top-10 |
| `minimax-m3.1-flash-free` | low, medium, high, xhigh, max | zero-retention, no training | reachable | top-15 |
| `nemotron-3.5-super-vl-free` | none ... xhigh | trial, logged | reachable | top-20 |
| `nemotron-3.5-lightning-free` | none | trial, logged | reachable | top-25 |
| `longcat-2.5-free` | none | zero-retention, China-hosted, 100 req/day | reachable | unranked |
| `flint-40b-free` | low ... max | may improve, 30-day retention | reachable | unranked |
| `beam-free` | low ... max | no training, 30-day retention, geo-restricted | reachable | unranked |
| `mimo-v2.6-flash-free` | none | may improve | reachable | unranked |
| `iceman-free` | none | retained and used for improvement | reachable | unranked |
| `big-pickle` | none | may improve | reachable | unranked |
| `inkling-2-small-free` | none ... max | retains, may train, geo-blocked | **geo-blocked** | unranked |
| `nemotron-3-ultra-free` | unknown | trial, logged | **unavailable** | N/A |

*Arena rank column shows approximate position on the open-source leaderboard as of
2026-11-14. "Unranked" means the model family does not appear on the open-source
filtered leaderboard. Check the live leaderboard for current rankings.*

`nemotron-3-ultra-free` appeared in the documentation but not in the runtime
catalog and failed the probe with `Model unavailable`. `inkling-2-small-free`
was `active` in the runtime catalog and failed with
`This model is not available in your country`. These two examples are why the
workflow requires a live probe.

## Observed snapshot — OpenRouter (free tier)

| Model ID | Variants | Privacy class | Probe | Arena rank (open-source) |
| --- | --- | --- | --- | --- |
| `meta-llama/llama-3.1-8b-instruct:free` | none | may improve (logged for moderation) | reachable | top-15 |
| `meta-llama/llama-3.1-70b-instruct:free` | none | may improve (logged for moderation) | reachable | top-10 |
| `mistralai/mistral-7b-instruct:free` | none | may improve (logged for moderation) | reachable | top-20 |
| `google/gemma-2-9b-it:free` | none | may improve (logged for moderation) | reachable | top-25 |
| `qwen/qwen-2.5-7b-instruct:free` | none | may improve (logged for moderation) | reachable | top-30 |
| `microsoft/phi-3-mini-128k-instruct:free` | none | may improve (logged for moderation) | reachable | top-35 |

*OpenRouter free models are hosted by OpenRouter; privacy varies by upstream
provider. Most log prompts for moderation/safety. Check each model card for
current terms.*

## Observed snapshot — NVIDIA (free tier)

| Model ID | Variants | Privacy class | Probe | Arena rank (open-source) |
| --- | --- | --- | --- | --- |
| `nemotron-3-ultra` | none | trial, logged | reachable | top-10 |
| `nemotron-3-ultra-vl` | none | trial, logged | reachable | top-12 |

*NVIDIA free endpoints are trials. NVIDIA may log data for model improvement.
Do not submit confidential code. Check <https://build.nvidia.com> for current
terms.*

## Privacy notes by provider

### OpenCode Console
- **Zero-retention:** GLM-5.3-Flash Free, DeepSeek V4.1 Flash Free, MiniMax
  M3.1 Flash Free, and LongCat 2.5 Free. LongCat is hosted in China and limited
  to 100 requests per day.
- **Retained without training:** Beam Free retains inputs for 30 days for
  safety and is unavailable in several regions.
- **May improve the model:** Big Pickle, Iceman Free, Flint 40B Free, and
  MiMo-V2.6-Flash Free.
- **Trial logging:** the Nemotron free endpoints are NVIDIA trials. Do not
  submit personal or confidential data.
- **Retained and possibly training:** Inkling 2 Small Free retains inputs and
  may use them for training; it is also unavailable in the EU, Iceland,
  Liechtenstein, Norway, Cuba, Iran, North Korea, Russia, Ukraine, and
  Venezuela.

### OpenRouter
- Free models are hosted by OpenRouter; upstream provider policies apply.
- Most free models log prompts for moderation/safety ("may improve" class).
- Some providers (e.g., Meta, Mistral, Google) have their own data policies.
- Check each model card on OpenRouter for current privacy terms.

### NVIDIA
- Nemotron free endpoints are trials; NVIDIA may log data for model improvement.
- Do not submit personal or confidential data to free NVIDIA endpoints.
- Check <https://build.nvidia.com> for current terms per model.

Always re-read the current Privacy section for each provider; this summary is
not legal advice.

## Rate limits by provider

### OpenCode Console
- **Daily request limit:** not published as a single number (FAQ stated 200/day in Oct 2026; as of Nov 2026 no number given).
- **Per-model exception:** LongCat 2.5 Free explicitly limited to 100 requests/day.
- **Scope:** limit is per account/network/IP, not per model. All free models share the same bucket.
- **Reset:** 00:00 UTC daily.
- **Nature:** dynamic — "always shifting based off what capacity we have vs demand" (OpenCode team). Measured limits have varied from ~170 to ~900 requests/day.
- **Error:** `Free usage limit reached` / `RateLimit.FreeUsageLimitError` with reset time shown.

### OpenRouter
- **Free models (IDs ending in `:free`) and `openrouter/free` router:**
  - 20 requests/minute (always)
  - 50 requests/day if all-time credits purchased < 10
  - 1,000 requests/day if all-time credits purchased ≥ 10 (one-time threshold; starts at 9 credits to absorb fees)
- **Tier basis:** all-time credits purchased, not current balance. Buying once lifts the cap permanently.
- **Negative balance:** blocks free models with HTTP 402.
- **Upstream provider limits:** also apply independently; many 429s come from providers, not OpenRouter.
- **Failed requests:** do not count toward daily cap (per community testing).
- **Check quota:** `GET /api/v1/key` → `free_model_daily_requests` (used, limit, remaining).

### NVIDIA (NIM / build.nvidia.com)
- **Published ceiling:** ~40 requests/minute (global across all models, not per-model).
- **Daily:** up to 10,000 requests/day per account (vendor's published ceiling).
- **Account:** requires NVIDIA Developer Program (free) + phone verification in supported country.
- **Geo-restrictions:** not offered in Russia, Pakistan, Bangladesh, Iran, Kazakhstan, Belarus, Uzbekistan, Kyrgyzstan, and others (~5.5% of developers).
- **Use case:** prototyping, research, development, testing only. Production requires NVIDIA AI Enterprise license.
- **Model registration:** some models require additional per-model-family registration (403 if not registered).
- **Credit system:** legacy credit system removed; "rate will vary per model queried" (NVIDIA staff). 40 RPM is from user reports, not official docs.

## Deprecation checks

The documentation maintains a deprecation table. Check both the family and the
exact version. For example, DeepSeek V4 Flash was deprecated on 2026-10-26, but
DeepSeek V4.1 Flash Free is a different model. Selecting a model by family name
is unsafe; always pin the exact ID.

## Role patterns

| Pattern | Assignment | Caveat |
| --- | --- | --- |
| Quality-first | DeepSeek architect, GLM orchestrator, Nemotron planner/worker, MiniMax reviewer | Nemotron is trial-logged |
| Privacy-first | DeepSeek architect/planner, GLM orchestrator/reviewer, MiniMax implementer/explore | zero-retention throughout |
| Speed-first | DeepSeek architect, GLM low orchestrator, Nemotron Lightning planner/explore, Nemotron Super VL worker, MiniMax reviewer | non-confidential work only |
| Maximum independence | implementer and reviewer on different families | more provider configuration |

These are patterns, not fixed assignments. Re-verify the models and preserve the
privacy class when substituting.

## Quality ranking with LMSYS Chatbot Arena

When multiple models are available in the same privacy class and reachability
tier, use the [LMSYS Chatbot Arena leaderboard](https://arena.ai/leaderboard/agent?license=open-source)
(filtered to **open-source license**) as an independent quality signal for
pyramid construction:

1. **Filter** the Arena leaderboard to open-source models only (`?license=open-source`).
2. **Cross-reference** models that appear in both the OpenCode free catalog and
   the Arena (e.g., DeepSeek, GLM, Nemotron, MiniMax families).
3. **Rank** candidates by Arena Elo for the role's primary capability:
   - Architect/Planner: overall reasoning and instruction-following Elo
   - Implementer: coding-specific Elo (if available) or overall
   - Reviewer: different family from implementer with highest Elo
   - Orchestrator/Explorer: throughput-oriented, mid-tier Elo acceptable
4. **Record** the Arena rank and date alongside the probe record. Re-check
   monthly; Arena rankings update weekly.

> Arena Elo is a relative signal, not an absolute guarantee. A model may score
> well on Arena benchmarks but fail on your specific codebase or task. Always
> combine with live probes and privacy classification.

## Sources

- [OpenCode Console models](https://opencode.ai/docs/console/models/) for the
  free catalog, variants, pricing, privacy, and deprecations.
- [OpenRouter free models](https://openrouter.ai/models?max_price=0) for model
  cards, variants, and upstream provider links.
- [NVIDIA Build](https://build.nvidia.com/explore/discover) for Nemotron and
  other NVIDIA model terms and availability.
- OpenCode runtime catalog and archived reachability probes, 2026-11-14.
- [LMSYS Chatbot Arena (open-source license filter)](https://arena.ai/leaderboard/agent?license=open-source) for independent
  quality rankings of open-source models. Use as a tie-breaker when multiple
  models share the same privacy class and reachability.
