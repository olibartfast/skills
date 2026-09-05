# Validation and Traceability

Define proof before implementation, then execute and record it honestly. Companion to
[thin-phase-planning.md](thin-phase-planning.md) (task-group exits) and the feature
packet's `validation.md`.

## Contents

- [Validation precedes implementation](#validation-precedes-implementation)
- [Requirements-to-evidence matrix](#requirements-to-evidence-matrix)
- [Baseline expectations](#baseline-expectations)
- [The validation ladder](#the-validation-ladder)
- [Recording commands and results](#recording-commands-and-results)
- [Evidence honesty](#evidence-honesty)
- [Do not weaken criteria to fit implementation](#do-not-weaken-criteria-to-fit-implementation)
- [Distinction from controlled benchmark runs](#distinction-from-controlled-benchmark-runs)

## Validation precedes implementation

Write `validation.md` as part of the feature contract, before any task group starts.
Success criteria defined after a solution exists tend to describe the solution rather
than the requirement. If the criteria are legitimately revised later, the revision is a
documented change in the same branch as the code — never an undocumented reset of the
bar to wherever the implementation stopped.

## Requirements-to-evidence matrix

Every in-scope requirement and out-of-scope boundary maps to at least one piece of
evidence. Template (use this table directly in `validation.md` or the hand-off report):

| ID | Requirement / boundary | Evidence type | Exact command or check | Result | Where recorded |
|----|------------------------|---------------|------------------------|--------|----------------|
| R-1 | `<observable behavior>` | focused test | `<cmd>` | pass/fail | `<log path/note>` |
| R-2 | `<empty/invalid/failure state>` | manual walkthrough | `<script or steps>` | pass/fail | `<note>` |
| R-3 | `<performance or constraint>` | regression/gate | `<cmd with threshold>` | pass/fail | `<log path/note>` |
| N-1 | out of scope: `<deferred work>` | diff review | scope diff inspection | confirmed absent | `<note>` |

Rules: a requirement row with no evidence row is an unverified requirement; an evidence
row not traceable to a requirement is likely scope creep to question.

## Baseline expectations

Record the pre-change state so a check result has meaning:

- **Environment:** OS/toolchain versions, key dependency versions, hardware where
  performance claims matter.
- **Reference run:** before implementing, run the validation commands on the unmodified
  tree and record which suites/commands pass, how long the suite takes, and known
  pre-existing failures. Pre-existing failures are not new evidence items — but note
  them so a "suite passed" claim cannot hide a flake.
- **For behavior/UX checks:** the current behavior being replaced, so before/after can be
  compared, not just "it works now".

## The validation ladder

Run, and record, from cheapest to most comprehensive. A higher rung only counts after the
rungs below it pass (or their failures are attributed to pre-existing issues with evidence).

1. **Static:** format, lint, type check, schema/dead-code checks.
2. **Focused tests:** tests targeting the changed behavior, success and failure paths.
3. **Regression:** the full existing test suite.
4. **Build/package:** production build or packaging, including the artifact claiming to
   work if the change claims it does.
5. **Manual behavior:** a real execution of the primary user/system-visible workflow,
   plus empty, invalid, and failure states. Include accessibility, responsiveness, and
   tone checks when the requirement touches them (visible UI, user-facing text,
   changelog/docs). Include migration checks (schema upgrade + downgrade, data from both
   shapes) when a migration is in scope.
6. **Scope diff:** inspect the whole diff against every in-scope requirement and every
   out-of-scope boundary; confirm deliverables and nothing more landed. This is the
   traceability step closing the matrix.

## Recording commands and results

Record exactly, per check: the exact command including working directory assumptions,
the exit status/pass/fail, output summary or log path for failures (paste the relevant
portion, not a paraphrase like "test failed"), and the date/revision. "I ran the tests"
is not evidence; the matrix's Result and Where columns are. For manual checks, record
what was done and observed — "walked the add-item flow empty → add → edit → delete on the
built sample" — not just "manual checks pass".

## Evidence honesty

- Run checks from the recorded commands in the validation document; do not summarize
  checks from memory or substitute close-enough commands without noting the difference.
- "Tests pass" ends the ladder at rung 3; it does not equal validation complete if the
  spec requires build, migration, accessibility, or walkthrough evidence.
- Failures are recorded as failures with output, either fixed or explicitly deferred to a
  named follow-up — never disappeared.
- Unverified, skipped, or redefined entries are labeled as such in the matrix.

## Do not weaken criteria to fit implementation

- Any change to a criterion (loosening a threshold, deleting a walkthrough, narrowing a
  scope row) requires an explicit rationale referencing a discovery, and updates
  requirements as well as validation in the same branch.
- Legitimate: the spec's requirement is revealed as wrong (e.g., the assumed library
  behaves differently on real data) — update the contract, re-validate the affected rows.
  Illegitimate: the implementation falls short — shorten the requirement to match.
- A quick honesty test: would the change have been made before implementation began?
  If no, it is a rationalization, not a revision.

## Distinction from controlled benchmark runs

In ordinary development you may loop: implement, run any relevant check, inspect, fix,
rerun — the compiler and test suite are the fastest feedback available, and re-running a
failed check after a fix is normal, expected work. The fixes need only be disclosed in
the final report, not counted.

That freedom does not apply inside controlled benchmark efforts governed by the
`orchestrate-ai-coding-workflows` skill. There, the acceptance command is fixed, the
tree starts clean at a known revision, the worker gets **one acceptance run as the final
action** (no accept-if-pass-repair-rerun loops), and results go to the run ledger and
scoreboard with planner/worker metrics per attempt. If your current task is a controlled
orchestrated attempt with an immutable acceptance command, defer to that skill's
scoring discipline; this document covers ordinary development only.
