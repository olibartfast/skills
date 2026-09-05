# Configuration and Measurement

How to make a coding-agent workflow configurable — model routing, permission
boundaries, and enforcement levers as committed, reviewable artifacts — and how
to measure it: a metrics catalogue, planner/worker separation, repeated
controlled comparisons, and an attempt log. Harness-agnostic where possible;
harness mappings only where verified.

Source basis: [AI Coding Workflows: From Cloud to Local](https://olibartfast.ninja/blog/ai-coding-workflows-cloud-to-local.html),
adapted into operational templates.

## Contents

- Run requirements
- Model routing configuration pattern
- Permission boundaries
- Metrics catalogue
- Planner/worker separation
- Repeated controlled comparisons
- Attempt log (run ledger)

## Run requirements

The four contract artifacts (intent, constraints, roadmap, acceptance tests)
belong under version control, unchanged for every run: the full definitions,
owner table, and scoreboard template live in
[workflow-contract.md](workflow-contract.md); the packet structure in
[delegation-and-handoff.md](delegation-and-handoff.md). Everything else is a
chat transcript that leaves with the session.

Additional rules for every measured run:

- One command decides the outcome (configure, build, test in one invocation).
  Record its exit status beside the token count; the attempt log records it
  below.
- The scoreboard command must actually rebuild; a bare `ctest` tests stale
  binaries — exactly the failure a worker will not notice.
- The scoreboard is not writable by what it scores; if a worker can edit the
  acceptance suite, a run can pass by weakening the check.
- Agent definitions, routing, and permission blocks are committed configuration,
  not typed prompts. Adding to the dependency manifest from within a run
  requires prior approval — recorded as a decision, not made silently.

## Model routing configuration pattern

Route by role, not by name. The split that pays is between judgement and
transcription:

| Role | Typical work | Tier |
|---|---|---|
| Architect / reviewer | Concurrency design, ownership and lifetime at boundaries, ABI questions, review that can reject | Strongest |
| Planner / orchestrator | Decompose a phase, write the handoff packet, chase the results | Mid |
| Implementer | Apply an agreed change against fixed interfaces under objective checks | Cheap or local |

A task belongs in the implementer tier only when the specification manufactured
it there: a bounded build target with named sources and a pass/fail preset
qualifies; "make this module thread-safe" does not. Sizing a packet tightly is
the lever that moves a job down a tier — not a better worker.

Routing belongs in per-agent configuration files, not in prompts, so the
worker's tier becomes a committed, reviewable artifact — e.g. a subagent
definition with `model: <provider>/<model-id>` (provider-qualified, so swapping
provider switches cloud ↔ local) and a turn/step ceiling. The full agent-file
template and its deny-by-default permission block are owned by
[permissions-and-local-inference.md](permissions-and-local-inference.md).

Harness mappings (verify against your version; these drift between releases):

| Lever | Claude Code | Codex | OpenCode |
|---|---|---|---|
| Worker tier | `model:` in `.claude/agents/*.md` | `model` in `.codex/agents/*.toml` plus planner `config.toml` | `model:`, provider-qualified |
| Loop ceiling | `maxTurns` — applies per invocation: a capped run returns a partial result, and the parent owns termination and continuation | none documented per agent — parent enforces | `steps` |
| Reachable tools | `tools:` / `disallowedTools:` | `sandbox_mode`, MCP allowlists | `permission:` keys |
| Write scope | edit permission rules (`Edit(path)` allow/deny) from session/project settings, inherited by subagents — good for immutable acceptance paths, but a single scope shared across phases, not distinct per-phase subagent allowlists | coarse (workspace) | fine (per-path allow/deny) |
| Behaviour brief | Markdown body | `developer_instructions` | Markdown body |
| Model choice scope | one vendor family | one vendor family | any provider, cloud or local |

Reasoning effort is configuration, not a detail: pin it explicitly on both sides
of any comparison or the result measures the setting, not the model.

Also watch for this failure: the planner seeing weak worker output quietly
rewrites the code itself. Cost returns to the single-model baseline while the
workflow still looks delegated. Instruct the planner to send defects back to a
fresh worker, and verify by checking which role consumed the tokens.

## Permission boundaries

The packet and the agent definition must agree on writable paths, so permission
blocks are regenerated per phase. Full allowlist template, read-only review
role, and clean-start discipline:
[permissions-and-local-inference.md](permissions-and-local-inference.md).

Scoping guidance for weak and local workers (example, not a default rule):
generated and vendored trees (`build/`, `node_modules/`, `third_party/`, and
similar) offer essentially no signal per token, and a weak or local worker that
lists or globs them floods its small context window and produces worse output.
Configure such workers to deny listing and globbing of those paths — searching
named files there may still be allowed. Reviewers keep broad read access: a
review that cannot see the generated tree can miss what was actually built.
Without a deny rule the weak worker's typical first action is enumerating the
noise instead of reading the packet's named sources.

## Metrics catalogue

Record the same columns for every configuration, split between planner and
worker.

| Metric | How to read it |
|---|---|
| Total context processed | Billed and re-read tokens per run and per role; a cost and repetition measure |
| Peak and average active context | How full the window actually got on a turn; this, not the total, predicts degraded output |
| Tool calls | Activity proxy, not work: a full build and a one-line read each count once |
| Turns | Interaction style, not work done; see caveat below |
| Wall-clock time | Useful but noisy; hardware load and network affect it |
| Metered cost | Zero for local inference, which is the point of going there |
| Outcome (first-pass validation result) | Correctness signal, taken before any repair by planner or human; the attempt log's recorded outcome — repairs are new attempts |
| Interventions | How often a human had to step in — the cost no dashboard shows |

Turns caveat: a small-model run had 45 turns against 6 with essentially
identical tool calls (57 vs 51) — smaller steps between actions, not more work.
Ranking by turn count alone produces a wrong conclusion.

Intervention count often reverses a decision: a configuration an order of
magnitude cheaper but needing three corrective rounds is not cheaper for paid
work.

Total-context vs active-context answer different questions: a session rereading
one header twenty times has large total and small active context — expensive
but not confused; one turn carrying a whole subsystem has the opposite profile,
and that is the one producing subtly wrong output.

## Planner/worker separation

Delegation relocates context pressure onto the orchestrator instead of removing
it; measured runs show worker sessions shrinking while planner context grew
nearly eightfold, with total context near flat.

Checklist:

- Always report planner and worker columns separately; aggregate totals hide the
  relocation and let you congratulate yourself on a saving that moved next
  door.
- Track tool calls and turns per role, not just globally.
- Treat orchestration as a designed workload: past some granularity you pay
  more to describe the work than to do it.
- Delegation on one model initially costs more (~50% more context and turns);
  the extra spend buys the planner/worker interface, and the return appears
  only when the worker changes tier. Judge it as an investment, not a saving.
- Record which role authored the final diff each round; rising planner token
  share is the signature of the rewrite-itself failure.

## Repeated controlled comparisons

Each configuration receives the same task, the same constraints, the same
starting revision, and the same judgement.

Checklist:

- Move one variable per comparison (worker tier, provider, permissions).
- Fresh context per run; revert to the starting commit afterwards (clean-start
  rules in [permissions-and-local-inference.md](permissions-and-local-inference.md)).
- Same prompt shape, same packet structure, same scoreboard command across runs.
- When changing model requires changing workflow (sizing, guardrails, packet
  beats), record the workflow differences with the results — those rows compare
  a different way of working, not just different weights.
- Run each configuration more than once; a single green result proves less than
  it appears to.
- Read results as evidence about direction and magnitude, not reproducible
  benchmarks; methodology transfers, figures do not (one small task, one
  machine, transient models).

## Attempt log (run ledger)

Record one entry per attempt — the unit is the attempt, not the phase or the
day. Failed attempts are recorded, not deleted.

```markdown
# Attempt log — <phase-id>

| Attempt | Config (role: model/provider) | Start SHA | Scoreboard cmd | Outcome | Interventions | Metrics | Notes |
```

Fields (columns match one-for-one):

- `attempt`: sequential, monotonic.
- `config`: role-to-model mapping actually used, provider included.
- `start-sha`: the exact commit the run began from, enabling clean-start audits.
- `scoreboard-cmd`: the single deciding invocation, as written in the workflow
  contract for the phase.
- `outcome`: the recorded scoreboard exit status for this attempt. Because the
  scoreboard runs exactly once per attempt as the final action (see
  [workflow-contract.md](workflow-contract.md)), this is by construction the
  pre-repair first-pass verdict — a repaired pass records a new attempt with
  its own outcome, rather than overwriting this row.
- `interventions`: count and one-line reason for every human step-in.
- `metrics`: context (total + peak per role), tool calls, turns, wall clock,
  metered cost, if captured.
- `notes`: workflow deltas from the comparison baseline, if any.

Update the log only against the run's recorded exit status; a worker partial to
its own success writes other files, not this one.

---

*Avoid committing secrets, absolute paths, or transient model identifiers to
any of the above; use capability tiers and role names, and read served model
IDs from the runtime.*
