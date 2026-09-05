# Thin Phase Planning

How to cut a product into thin, vertically reviewable slices, order them, and turn a slice
into task groups with observable exits. Companion to the spec-driven feature packet:
requirements describe what, the plan describes how, validation.md (see
[validation-and-traceability.md](validation-and-traceability.md)) describes proof.

## Contents

- [Why thin vertical slices](#why-thin-vertical-slices)
- [Thin-slice rubric](#thin-slice-rubric)
- [Dependency ordering](#dependency-ordering)
- [Task groups with observable exits](#task-groups-with-observable-exits)
- [Special work: migrations, interfaces, spikes, rollback](#special-work-migrations-interfaces-spikes-rollback)
- [What to avoid](#what-to-avoid)
- [Implementation checkpoints](#implementation-checkpoints)

## Why thin vertical slices

A slice touches storage, logic, and presentation (or producer, transform, consumer) so that
it can run end to end, however small. Thin horizontal layers ("do all models, then all
endpoints, then all UI") defer integration risk to the end, make review of an
uninhabitable mid-state mandatory, and let errors compound silently. Slices integrate
early; layers integrate late.

## Thin-slice rubric

A phase is thin enough when it satisfies all of these:

1. **Runnable** — after the slice, the product starts, runs, and demonstrates something,
   even if minimal. No slice ends in code that only compiles.
2. **Demonstrable to a non-implementer** — the exit can be shown in one or two minutes:
   "the list renders read-only", "the form saves and reloads".
3. **Independently reviewable** — the diff has one reviewable purpose; a reviewer can
   verify it without holding a second slice in mind. Target roughly one review sitting.
4. **Reversible or forward-safe** — reverting the slice leaves the product working, or the
   slice is genuinely additive and risk is accepted explicitly.
5. **Ungated by unfinished others** — no slice depends on a sibling slice in the same
   phase that has not been merged. If two slices must land together, they are one slice.
6. **Validatable** — the exit can be checked by command plus a short manual walkthrough,
   before the next slice starts.

If a phase fails the rubric, split it along a user-visible seam (a workflow, a state, a
screen), not along a technical seam (a module, a class).

## Dependency ordering

Order slices by what unblocks the most and risks the most:

1. **Walk before decorate:** working path → saved state → edge cases → polish/accessibility.
2. **Riskiest unknown first:** if one piece could invalidate the design (schema shape,
   protocol, third-party behavior), pull its smallest probe into the first slice.
3. **Shared before dependent:** an interface, migration, or seam slice precedes slices
   built on it — but the seam slice must itself be rubric-passing (e.g., migrate and read
   from both, not "move all data" as a black box).
4. **Allowed to regress downward:** replanned cost is acceptable; hidden dependency is not.
   If slice N cannot start because slice N-1's exit turns out false, stop and re-prep,
   recording the discovery.

## Task groups with observable exits

Inside a phase, order work as numbered task groups of 2–5 tasks. Each group's last task
must be an **exit check** — a command or an observable demonstration, not "review changes".

Template:

```
## Group 1 — Read path (repo + query)
1. Add the schema/migration for X.
2. Add the typed query/load function.
3. Exit: seed fixtures and show X loads via the repository script / test.

## Group 2 — User-visible slice
4. Implement the minimal behavior end to end.
5. Exit: manual walkthrough of the primary workflow; focused tests pass.

## Group 3 — Boundaries and states
6. Cover empty, invalid, failure states.
7. Exit: edge-case checklist from validation.md passes.

## Group 4 — Hardening
8. Add/update tests; run full validation commands.
9. Exit: every requirement row has evidence (see validation matrix).
```

Rules: never interleave groups; if group N's exit cannot run because group N-1's exit was
faked or skipped, stop. A group whose only exit is "it compiles" is not a group — merge it
into the group that makes the behavior observable.

## Special work: migrations, interfaces, spikes, rollback

- **Migrations.** One migration per schema change per slice, written before the code that
  uses it, reversible (with an explicit down path or a documented irreversible intent),
  and exercised against representative data — not just an empty database. The exit is
  "old and new data both read correctly", demonstrated.
- **Interface/seam slices.** When introducing an interface, adapter, or queue boundary,
  the first slice introduces the seam with one real implementation behind it and one
  call site switched over; later slices add implementations through the same seam. Never
  introduce a seam whose only consumer arrives three slices later.
- **Spikes.** Time-boxed, throwaway, and clearly labeled in the plan ("spike: answer
  whether X is feasible, deliverable = a written decision, not merged code"). A spike's
  exit is an answered question. Spike findings update requirements/plan before the real
  slice is planned; spike code is discarded unless the plan explicitly adopts it.
- **Rollback paths.** Slices that change data shape, persistence format, or an external
  contract must declare in the plan: how to revert, what happens to data produced under
  the new shape, and what the fallback behavior is. If no safe rollback exists, the slice
  gets a gate (test suite + manual sign-off) before any irreversible step, and the
  irreversible step is isolated as its own group.

## What to avoid

- **Horizontal layers as phases.** "Data model phase," "API phase," "UI phase" hide
  integration risk. Split along behavior instead; only risk-unknown-first probes may
  look horizontal, and they must be the smallest such probe.
- **Over-specified function-level plans.** Pre-naming functions, signatures, and internal
  structure locks in weak assumptions made before discovery. Specify observable behavior,
  data in/out, and consequential boundaries (process/module seams, persistence shape,
  external contracts); let naming and routine internal structure follow repository
  conventions found during implementation.
- **Phases that only plan.** "Design phase" with no runnable output is a spike or a
  requirements question, not a phase. Documentation-only work attaches to the slice that
  makes it true.
- **Dependency pyramids.** A phase that cannot deliver user- or system-visible value until
  three successors land is too big; thin it.

## Implementation checkpoints

Execute one group at a time:

1. **Before a group:** re-read its tasks and exit check; confirm the previous exit was
   actually observed (recorded command + result), not assumed from memory.
2. **During:** check related repository code first; reuse established components; deviate
   from the plan only on discovery, and record the discovery plus the spec/plan update it
   triggers in the same change (no silent code-only deviations). Preserve unrelated user
   changes: never revert, overwrite, or clean work you did not create. Adding a dependency
   requires a recorded feature decision; if it changes the stack, use the global-decision path.
3. **At the exit:** run the exit check and record the exact command and result. If the
   exit fails, fix within the group or stop and replan — do not continue to the next group
   on top of a failed exit.
4. **Between groups (human pause point):** for higher-risk slices, commit and request a
   mini-review per group; for small features, review the group diff before proceeding and
   commit at phase end. Either way, never let two groups' work mix in one unreviewed diff.
5. **At the last group:** hand off to the validation pass defined in
   [validation-and-traceability.md](validation-and-traceability.md).
