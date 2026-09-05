# Brownfield Spec-Driven Adoption

## Contents

- Why adoption is different from greenfield
- Step 1: Inventory what exists
- Step 2: Reconstruct, do not invent
- Step 3: Label provenance (evidence / inference / assumption)
- Step 4: Capture only stable boundaries
- Step 5: Roadmap unfinished work
- Step 6: Create feature packets only for active changes
- Step 7: Adopt incrementally
- Proportionality rubric (lightweight / standard / high-assurance)
- Failure-mode checks

## Why adoption is different from greenfield

In greenfield work, the spec precedes the code. In an existing codebase, current
behavior is primary evidence for the reconstructed spec. Writing the spec you
wish existed (instead of the one the system actually implements) produces
confident documents that fail at the first integration gate. The goal of
brownfield adoption is to reverse-engineer a minimal, provably accurate spec
layer, then use it only where active work needs it.

## Step 1: Inventory what exists

Before writing a single spec line, gather the current truth. Record where each
fact came from; you will reuse these as confirmation paths in Step 3.

- **README and docs**: stated architecture, onboarding, quickstarts. Flag
  statements that code can contradict (they age fastest).
- **Issue tracker**: open bugs are recorded gaps between expected and actual
  behavior — raw material for a "known deviations" section.
- **TODO / FIXME / HACK markers**: intentional incompleteness the authors
  already admitted. These belong in the roadmap, not the spec.
- **Manifests and dependency declarations**: supported runtimes, dependency
  versions, feature/enabled flags — cheap, verifiable facts.
- **Build system**: targets, configurations, toggles. What can be built is part
  of the interface.
- **Tests**: read tests as executable documentation. What they assert is
  *confirmed behavior*; gaps they leave are unconfirmed behavior.
- **Recent history**: last 3–6 months of commits, PR descriptions, revert
  commits. Recent churn identifies the hot areas active work will touch — the
  only areas an early spec must cover.
- **Current behavior**: for hot areas, describe what the system *does* by
  running it or tracing it, not what naming suggests it should do.

Output: a short inventory note per area with links to sources.

## Step 2: Reconstruct, do not invent

Write the spec bottom-up from the inventory. For every claim ask: "which
inventory item says this?" If nothing does, either go find evidence or mark and
park it. Never draft an aspirational spec ("the module should…") against code
that already says otherwise — spec-first wording is reserved for genuinely new
work delivered in feature packets.

Practical moves:

- Describe observable behavior (inputs, outputs, side effects, error paths)
  before internal design.
- Where the implementation is clearly accidental (legacy naming, accidental
  coupling), name the *current* truth in the spec and record the desired
  direction in the roadmap — one document, two truths, clearly separated.
- Prefer linking to the confirming artifact (test, file, commit) over
  paraphrasing it; links stay auditable.

## Step 3: Label provenance (evidence / inference / assumption)

Every claim in a reconstructed spec gets one of three labels:

- **Evidence**: directly confirmed by an artifact (a passing test, a compile
  flag, a documented and matching behavior). Highest trust.
- **Inference**: derived from evidence (e.g., "retry policy is 3× jittered
  backoff because tests exercise it and constants appear in config").
  State the derivation source.
- **Assumption**: believed but unverifiable so far (e.g., behavior under
  conditions nothing exercises). Explicitly parked for confirmation.

Add a tight confirmation workflow:

1. Draft with labels inline, e.g. ``(inference: depends on `maxRetries`
   constant in config/schema.py)`` — compact and unambiguous.
2. Route assumptions to the right confirmation path:
   - **Maintainers**: ask about intent ("is the 5s timeout contractual?").
     Turns assumptions about *purpose* into evidence quickly.
   - **Executable checks**: write or run a probe, test, or script that
     demonstrates or refutes the behavior. Turns assumptions about *behavior*
     into evidence without waiting on anyone.
3. After confirmation, upgrade the label and add the confirming link. Anything
   still labeled `assumption` after the gate in
   [integration-spec-sync-and-replanning.md](integration-spec-sync-and-replanning.md) must be
   explicitly accepted as risk by the roadmap owner.

A spec where most claims are evidence is trustworthy enough to drive agents;
one full of lingering assumptions is not.

## Step 4: Capture only stable boundaries

Do not spec-dump the whole module. A reconstructed spec is expensive to keep
accurate; write it only at boundaries that are (a) already stable and (b) going
to be touched:

- Public APIs, module interfaces, wire/serialization formats.
- Configuration surfaces (flags, env, config files).
- Build/install/dependency contracts other teams rely on.
- Behavior other teams keep tripping over (error and failure semantics).

Explicitly *not* to capture now: internal algorithms, helper functions,
implementation details of code with no pending change. Name their location,
not their content: "config resolution internals: see `resolveConfig()`, no spec
yet (stable, untouched)."

Rule of thumb: if a change to the described thing would break a consumer you
can name, spec it. Otherwise leave it to the feature packet that touches it.

## Step 5: Roadmap unfinished work

Turn inventory TODOs, open issues, and the "desired direction" records from
Step 2 into a roadmap entry set. Keep each entry one line plus a link:

- `- [ ] consolidate three retry paths — see TODO in net/client.cpp, #142`

The roadmap is the bridge: it tells future work where incomplete transition
areas live and prevents the next contributor from treating "no spec yet" as
"nothing to do". Mark which entries will require a feature packet when started.

## Step 6: Create feature packets only for active changes

Once the baseline exists, switch to greenfield-style discipline *per change*:
a short packet with intent, requirements, a task-level plan, and validation
criteria, kept alongside the actual work. Never write speculative packets for
roadmap items "while we're at it" — packets written without the pressure of an
active change rot immediately and mislead.

A packet applies to:

- new feature work in a brownfield area,
- a refactor or migration of one of the captured stable boundaries,
- any change spanning more than one module or more than one person's session.

It does not apply to trivial fixes or drive-by changes; those still update the
spec only if they touch a captured boundary.

## Step 7: Adopt incrementally

Sequence adoption by leverage, not by architecture diagram:

1. Inventory (Step 1) for the whole codebase — cheap, do it up front.
2. Reconstruct specs for the 1–3 hot boundaries identified from recent
   history, plus the roadmap (Steps 2–5).
3. Require a feature packet for the next active change; validate the workflow
   itself against that change (did the packet help? what was missing?).
4. Extend spec coverage only when work moves into new areas.
5. Retro after the first 2–3 adopted changes; prune spec content that measured
   as never-read.

Do not attempt "full documentation before we write code again" — it
concentrates cost up front, goes stale, and gets abandoned. Adoption should pay
for itself within the first two changes.

## Proportionality rubric

Choose the depth per change or per area; the rubric weights four factors:
**ambiguity** of the problem, **risk** of getting it wrong, **handoff**
(whether someone else, often an agent, must execute), and **multi-step scope**
(number of dependent steps/areas).

| Tier | Criteria (any two) | What you produce |
|---|---|---|
| **Lightweight** | Low ambiguity, low risk, single owner, ≤3 steps | A short spec-level note in the PR/commit or a mini feature packet (intent + do-not-break list + validation criteria). No separate plan. |
| **Standard** | Moderate ambiguity or moderate risk, handoff to another executor, 3–10 steps across 1–2 modules | Feature packet with intent, requirements, task plan, validation criteria; spec updated at touched boundaries in the same branch. |
| **High-assurance** | High ambiguity or high blast radius, agent/multi-session handoff, >10 steps, multiple dependent areas, or an invalid-assumption aftermath | Full spec + plan + validation document structure, extracted from evidence only; staged gates (intent, plan, per-phase); explicit replanning checkpoints; provenance labels mandatory. |

Tie-breakers:

- When risk is unclear, escalate one tier; downgrade again in the retro.
- Any change whose validation would be "looks right" by inspection needs at
  least standard tier.
- Never let tier selection itself become a meeting: pick, note why, move on.

Matches the source workflow's advisory stance: gates and heavyweight docs are
introductions, not religion — scale with what the work actually needs.

## Failure-mode checks

Run these checks whenever adopting, drafting, or reviewing a brownfield spec.

1. **Giant prompt / giant spec**: if the spec is a thousand lines, nobody will
   read it and agents will truncate it mentally. Spec content must be
   *contextually* consumed: split into granular (per-phase, per-requirement)
   documents and load what the task needs. Anti-signal: any single document a
   reviewer reads less than once end-to-end.
2. **Spec theater**: writing extensive specs because it feels disciplined,
   not because they inform work. Anti-signals: nobody consults the spec when
   implementation questions arise; last spec change predates all recent feature
   work. Check: can you point to a decision the spec materially changed?
3. **Over-specification**: detailing internal algorithms, data schemas, and
   design minutiae with no requirements grounding. This forces co-evolution and
   stands dead in the way of refactoring. Check: would this item still be true
   after a behavior-preserving internal refactor? If yes, cut it.
4. **Late validation**: leaving all verification to the end. There is always a
   temptation to implement-and-fail-fast; it erodes trust in the spec. Check:
   does every phase of the plan have its own validation criteria before the
   next phase starts?
5. **Silent assumptions**: unstated "should be obvious" constraints (implicit
   invariants, API contracts) that agents cannot infer from code alone. Check:
   for each plan item, is every assumption written down? Anything justified
   with "everyone knows…" must be promoted to an explicit (labeled) statement.
6. **Frozen specs**: treating a spec as an unchangeable contract after
   implementation reveals new constraints. Anti-signal: spec diff is empty
   after a project that visibly changed understanding. Check: is there a
   process to update spec, plan, and code together (see
   [integration-spec-sync-and-replanning.md](integration-spec-sync-and-replanning.md))?
7. **Microscopic specs**: counter-failure to #1 — fragmenting into so many
   tiny documents that cross-cutting intent, invariants, and architecture have
   no home, and consistency across fragments is unchecked. Check: is there a
   living overall specification, and does each small doc locate itself in it?

Adopting teams should re-run the checks at each retro (Step 7, item 5) and track
violations found-and-fixed; a check that never fires should be reworded into
something actionable.
