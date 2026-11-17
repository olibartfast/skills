---
name: select-opencode-free-models
description: Select and verify OpenCode free models for agent roles against privacy, geography, availability, rate-limit, and deprecation caveats. Use when choosing free models for coding agents, building multi-model pyramids, checking whether a free model is reachable in a region, or avoiding providers that log, retain, or train on inputs.
---

# Select OpenCode Free Models

Free removes cost, not risk. Free OpenCode models differ in privacy terms,
regional availability, request caps, quality, and how long they will exist.
Treat "free" as a temporary entitlement that must be verified per role and
re-verified before long or sensitive runs.

## Boundary

This skill covers free models accessible through OpenCode, including:

- **OpenCode Console free tier**: models referenced as `opencode/<model-id>`
- **OpenRouter free models**: models referenced as `openrouter/<model-id>` (e.g., `openrouter/meta-llama/llama-3.1-8b-instruct:free`)
- **NVIDIA free models**: models referenced as `nvidia/<model-id>` (e.g., `nvidia/nemotron-3-ultra`)
- **Other providers**: any provider configured in OpenCode that offers free models

Paid Console models are out of scope. The catalog changes without notice; every
table here is a dated snapshot, not a contract.

## Workflow

1. Classify the work.
2. Read the current catalog.
3. Probe reachability.
4. Classify privacy and retention.
5. Assign roles and fallbacks.
6. Record the choice and re-verify.

### 1. Classify the work

Capture these before selecting a model:

- **Confidentiality:** can the source, prompts, or outputs leave the trust
  boundary? This decides whether logged and training models are allowed.
- **Region:** some models are geo-blocked. A catalog entry does not prove the
  account's region can reach it.
- **Volume:** fan-out and long sessions can hit daily caps or rate limits.
- **Role:** architecture and review need reasoning; implementation needs code
  quality and throughput; exploration needs latency.
- **Independence:** a reviewer should not share the implementer's model family
  when a real second opinion matters.
- **Lifetime:** free models are time-limited. Have a same-privacy-class
  fallback.

### 2. Read the current catalog

- **OpenCode Console**: <https://opencode.ai/docs/console/models/> lists the free
  model set, variants, prices, privacy notes, and deprecations.
- **OpenRouter**: <https://openrouter.ai/models?max_price=0> filters free models;
  check each model's "Context" and "Architecture" tabs for privacy/retention.
- **NVIDIA**: <https://build.nvidia.com/explore/discover> lists Nemotron and other
  models; free tiers are marked. Review NVIDIA's data usage policy per model.
- **Runtime**: `opencode models`, or `/models` in the TUI, lists what this account
  can actually select across all configured providers.
- Reference a model as `<provider>/<model-id>` with an optional variant, such as
  `opencode/deepseek-v4.1-flash-free#max` or `openrouter/meta-llama/llama-3.1-8b-instruct:free`.
- Quality ranking: cross-reference candidates with the [LMSYS Chatbot Arena
  leaderboard (open-source filter)](https://arena.ai/leaderboard/agent?license=open-source)
  for independent Elo ratings. Use as a tie-breaker when multiple models share
  the same privacy class and reachability.

When documentation and runtime disagree, use the docs for contractual terms and
the runtime for entitlement. Both can be stale; probe before trusting either.

### 3. Probe reachability

Catalog status is not reachability. Probe the exact model and variant:

```sh
# OpenCode Console
opencode run --archived --model opencode/deepseek-v4.1-flash-free "Reply with exactly: OK"

# OpenRouter
opencode run --archived --model openrouter/meta-llama/llama-3.1-8b-instruct:free "Reply with exactly: OK"

# NVIDIA
opencode run --archived --model nvidia/nemotron-3-ultra "Reply with exactly: OK"
```

`--archived` keeps probe sessions out of normal history. To probe a set, run
[`scripts/probe-free-models.sh`](scripts/probe-free-models.sh) (update the script
for your provider list).

| Result | Meaning | Action |
| --- | --- | --- |
| prints `OK` | reachable | keep |
| `Model unavailable` | not in runtime catalog or not entitled | replace |
| `not available in your country` | geo-block | replace; do not retry |
| timeout | endpoint or network stall | retry once, then replace |
| 429 or quota text | rate or daily cap | move the role or reduce fan-out |

A model can be `active` in the catalog and still fail. Record the probe date.

### 4. Classify privacy and retention

Read the current privacy/retention policy for **each provider and model** before
using a free model on non-public code. Sort candidates into four classes:

| Class | Meaning | Typical use |
| --- | --- | --- |
| Zero-retention, no training | provider states no retention and no training | confidential code, subject to policy |
| Retained, no training | short safety retention only | internal but not secret |
| May improve the model | inputs may be used for improvement | public or disposable code |
| Trial or training | logged trial data or training use | public or synthetic code only |

**Provider-specific notes:**
- **OpenCode Console**: Privacy class documented per model in Console docs.
- **OpenRouter**: Varies by upstream provider. Check the model card on OpenRouter
  and the original provider's policy. Many free models log prompts for moderation.
- **NVIDIA**: Nemotron free endpoints are trials; NVIDIA may log data. Do not
  submit confidential code.
- **Other providers**: Check each provider's terms; free tiers often have weaker
  privacy than paid.

Never infer a privacy class from the model name. Providers change terms, and
free endpoints often differ from the paid model of the same family.

### 5. Assign roles and fallbacks

| Role | Prefer | Reason |
| --- | --- | --- |
| Architect, planner | strongest reasoning model, high variant | design quality drives everything downstream |
| Orchestrator | reliable instruction-follower, mid or high variant | coordination, no edits |
| Implementer | strong coding model, high variant | correctness and iteration speed |
| Reviewer | different family from the implementer, high variant | independent failure modes |
| Explorer | fast, low variant | high volume, low stakes |

When multiple models are available in the same privacy class and reachability
tier, use the [LMSYS Chatbot Arena](https://arena.ai/leaderboard/agent?license=open-source)
(open-source license filter) to rank candidates by Elo for the role's primary
capability:
- Architect/Planner: overall reasoning and instruction-following Elo
- Implementer: coding-specific Elo (if available) or overall
- Reviewer: different family from implementer with highest Elo
- Orchestrator/Explorer: throughput-oriented, mid-tier Elo acceptable

**Cross-provider fallback chains (privacy-class aligned):**

| Privacy class | Example chain |
| --- | --- |
| Zero-retention | `opencode/deepseek-v4.1-flash-free` → `opencode/glm-5.3-flash-free` → `opencode/minimax-m3.1-flash-free` |
| May improve | `openrouter/meta-llama/llama-3.1-8b-instruct:free` → `openrouter/mistralai/mistral-7b-instruct:free` |
| Trial/logged | `nvidia/nemotron-3-ultra` → `opencode/nemotron-3.5-super-vl-free` |

Do not fall back from a zero-retention model to a trial-logged one just to keep
working. Prefer same-provider fallbacks for simpler config; cross-provider for
independence.

Variant support differs by model. Use only a variant the model advertises in
the model picker or provider metadata. A wrong variant fails at request time,
not at config load.

### 6. Record and re-verify

Record model ID, variant, role, privacy class, region result, and probe date in
the project or agent config. Re-probe:

- before a long or expensive run;
- after any `Model unavailable`, geo-block, or quota error;
- when the Console documentation changes;
- when a free model is withdrawn or deprecated.

## Rate limits by provider

| Provider | Free tier limits | Notes |
| --- | --- | --- |
| **OpenCode Console** | Daily request limit (undocumented); LongCat 2.5 Free: 100/day | FAQ used to state 200/day (Oct 2026); as of Nov 2026 no single number published. Limit is per account/network/IP, not per model. Resets at 00:00 UTC. Dynamic based on capacity vs demand. |
| **OpenRouter** | 20 RPM; 50 RPD (< 10 credits lifetime) or 1,000 RPD (≥ 10 credits) | Applies to all `:free` models and `openrouter/free` router. Tier based on all-time credits purchased (one-time threshold). Negative balance → 402 errors. Upstream provider limits also apply. |
| **NVIDIA (NIM)** | ~40 RPM (global across all models); up to 10,000 RPD | Requires NVIDIA Developer Program account + phone verification. Not available in Russia, Pakistan, Bangladesh, Iran, Kazakhstan, Belarus, Uzbekistan, Kyrgyzstan, and others. Prototyping only; production needs NVIDIA AI Enterprise license. Some models require additional per-model-family registration. |

## Failure handling

- **Model unavailable:** remove it from the config and use the same-class
  fallback. Do not silently downgrade privacy.
- **Geo-blocked:** replace it. Retrying cannot change the region.
- **Rate limited:** move the role to another family, reduce parallelism, or
  lower the number of delegated agents. Check provider-specific limits above.
- **Deprecated:** migrate before the removal date; check the deprecation table
  for both the family and the exact version.
- **Unexpected quality drop:** re-check the selected variant and whether the
  free alias now points at a different backend.

## Anti-patterns

- Treating a catalog row as proof of entitlement.
- Sending confidential code to trial-logged or training models.
- Assigning every role to one provider family.
- Using a daily-capped model for fan-out work.
- Hardcoding a free model with no fallback.
- Confusing a deprecated base model with its current free variant.

## References

- [references/model-caveats.md](references/model-caveats.md): dated snapshot of
  the free catalog, privacy classes, and observed probe results.
- [references/verification.md](references/verification.md): commands,
  interpretation, and a recording template.
- [scripts/probe-free-models.sh](scripts/probe-free-models.sh): batch
  reachability probe using archived sessions.
