# OpenCode Free Model Caveats

Snapshot: 2026-11-14. Provider: `opencode` (OpenCode Console free tier).
Sources: Console model documentation, the live runtime catalog, and
per-model reachability probes. Free availability is time-limited; re-run the
probes before relying on this table.

## Observed snapshot

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

## Privacy notes

The Console documentation lists these restrictions during the free period:

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

Always re-read the current Privacy section; this summary is not legal advice.

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
- OpenCode runtime catalog and archived reachability probes, 2026-11-14.
- [LMSYS Chatbot Arena (open-source license filter)](https://arena.ai/leaderboard/agent?license=open-source) for independent
  quality rankings of open-source models. Use as a tie-breaker when multiple
  models share the same privacy class and reachability.
