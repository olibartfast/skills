# Artifact Templates for Spec-Driven Development

Practical Markdown templates for spec-driven development. Copy them, trim
sections that do not apply, and keep every artifact reviewable in minutes.

Shorthand to keep in mind while filling them in:

- **requirements = what** — the contract: behavior, boundaries, decisions.
- **plan = how** — ordered, independently verifiable work.
- **validation = proof** — the exact evidence that the contract is met.

## Contents

1. [Conventions used by the templates](#conventions)
2. [`specs/mission.md` — project mission](#mission)
3. [`specs/tech-stack.md` — technical boundaries](#tech-stack)
4. [`specs/roadmap.md` — delivery sequence](#roadmap)
5. [`specs/<date>-<feature>/requirements.md`](#requirements)
6. [`specs/<date>-<feature>/plan.md`](#plan)
7. [`specs/<date>-<feature>/validation.md`](#validation)

## Conventions

- Keep the constitution (`mission.md`, `tech-stack.md`, `roadmap.md`) short
  enough to read before every feature-planning session. It should change
  rarely; feature packets change per phase.
- Name feature directories `specs/YYYY-MM-DD-<feature-slug>/` so parallel or
  repeated efforts are distinguishable and history stays searchable.
- Use stable IDs (`R-1`, `D-1`, `V-1`, `T-2` …) so requirements, tasks, and
  evidence can reference each other without ambiguity.
- Every statement should fall into exactly one bucket: a *finding* (observed,
  citable), an *inference* (derived, plausible, confirmable), or an
  *assumption* (accepted without evidence, usually about the future).
- Record deviations honestly: "checked" means the command was actually run
  or the manual walkthrough actually happened, not that it probably would.

---

## Mission

Answers: *Why does this product exist, and for whom?*

```markdown
# Mission — <Product Name>

## Problem
<One or two sentences: the concrete problem users have today.>

## Audience
<Who this is for, and who it is explicitly not for.>

## Product Promise
<What the product delivers that makes it worth using. One paragraph.>

## Success Criteria
- <Measurable or observable outcome 1>
- <Measurable or observable outcome 2>

## Product Principles (optional)
- <Tone, quality bars, or values that should shape every feature>

## Open Questions
- [Q-N] <Question, owner, deadline for resolution>

_Revision: YYYY-MM-DD — <what changed and why>_
```

## Tech Stack

Answers: *What technical boundaries should every feature respect?*
Explicit **non-choices** matter: they stop scope creep driven by
convenience.

```markdown
# Tech Stack — <Product Name>

## Fixed (must not be changed per feature)
- Language(s): <…>
- Frameworks / key libraries: <…>
- Data store: <…>
- Testing approach: <…>
- Build / CI basics: <…>

## Preferred (follow unless there is a recorded reason not to)
- <Pattern or tool with a short rationale>

## Open (decide per feature, record the decision)
- <Area where the right choice is still unknown>

## Explicit Non-Choices
- <e.g. No ORM in the first release> — <one-line rationale>
- <e.g. No client-side framework> — <one-line rationale>

## Constraints (cross-feature)
- <Compatibility, security, performance, licensing, operational limits>

## Open Questions
- [Q-N] <Question, owner>

_Revision: YYYY-MM-DD — <what changed and why>_
```

## Roadmap

Answers: *What is the smallest sensible delivery order?* Phases must be
thin, independently reviewable, and end in something observable. "Render
the shell", then "show a read-only list", then "add one editable
workflow" — not "build the dashboard".

```markdown
# Roadmap

Status values: `idea` · `planned` · `in progress` · `done` · `blocked` · `deferred`

## Phase 1 — <name>
- Status: <status; for done/blocked, link the validation or blocking evidence>
- Outcome: <one observable result>
- Proves: <what this slice validates about stack or value>
- Spec: `specs/<date>-<slug>/`   Branch: `<branch-name>`

## Phase 2 — <name>
- …

## Deferred / Revisit
- [<Item, why it was moved>]

_Revision: YYYY-MM-DD — <what changed and why>_
```

Rules:

- Order phases by dependency and risk, not chronology of ideas.
- Re-plan after each delivered phase; several small phases may now belong
  together, or a discovery may need an earlier spike.
- Updating the roadmap at integration time is part of the workflow, not a
  failure of the original plan.

---

## Requirements

The contract: **what** this phase must deliver. Write it before the plan and
validation; they derive from it.

```markdown
# Requirements — <Feature Name>

Spec: `specs/<date>-<slug>/requirements.md` · Branch: `<branch>` · Roadmap: Phase <N>

## Goal
<One or two sentences: the user- or system-visible outcome.>

## In Scope
- [R-1] <Observable behavior included in this branch>
- [R-2] <…>

## Out of Scope
- <Related work deliberately deferred, and why / where it lands>

## Decisions
- [D-1] <Choice> — Rationale: <why, including any constitution it touches>
- [D-2] <…>

## Constraints
- <Constitution rules, compatibility, security, performance limits that apply>

## Dependencies
- <From codebase: components/config this relies on, with evidence or confirmed inference>
- <External: services, data, approvals>

## Context
- <Existing patterns, tone, operational realities that shape the work>
- <Source of each item: file/link, or label it as an inference/assumption>

## Assumptions & Open Questions
- [A-1] <Assumption> — Basis: <…>   (promote to an interview question if material)
- [Q-N] <Open question, owner>      (resolve before implementation if material)

## Definition of Done (requirements level)
- [ ] Every [R-n] is implemented or explicitly deferred with a tracked location
- [ ] No In Scope behavior silently dropped; no Out of Scope work smuggled in
```

Guidance:

- **In/out scope** is the primary creep detector. Anything not listed as in
  scope is out of scope by default.
- Record decisions precisely when the obvious implementation would violate
  the constitution or contradict an earlier decision.
- Keep context brief and sourced. Unverified repo reconstructions go here
  as labeled inferences, not as facts.

## Plan

The sequence: **how** to build it. Numbered task groups that follow
dependency order, each ending in something observable or checkable.

```markdown
# Plan — <Feature Name>

## Group 1 — <name>
- [T-1] <Task> — Deliverable: <observable result>
- [T-2] <Task> — Deliverable: <…>
  - Checks: <closest command or inspection to run here>

## Group 2 — <name>
- [T-3] <Task>
- [T-4] <Task>

## Group N — Verification
- [T-x] Add or update tests for [R-1], [R-2]
- [T-y] Execute everything in `validation.md`

## Notes
- <Conventions discovered and reused, component reuse, anything that
  deviated from the plan and why>
```

Rules:

- Task groups are implementable and verifiable independently; a failure in
  one group should be localizable without re-reading the whole feature.
- Specify behavior and consequential architecture only. Routine naming and
  file placement follow repository conventions — do not lock weak
  assumptions into the plan before discovery.
- The plan guides; it does not replace repository discovery. Inspect
  existing code and reuse established components.

## Validation

The proof. **Write this before implementation.** Criteria defined after the
code exists tend to fit whatever was built rather than what was required.

````markdown
# Validation — <Feature Name>

## Automated Checks
Run from the repository root:

```text
<exact command, working directory, expected exit state>
```
- [ ] <Static: format/lint/typecheck/schema — command + evidence note>
- [ ] <Focused tests covering [R-1]/[R-2] success and failure paths>
- [ ] <Full regression suite>
- [ ] <Build or packaging check>

## Manual Checks
- [ ] [M-1] <Primary workflow walkthrough: steps + expected observation>
- [ ] [M-2] <Empty / invalid / failure states usable>
- [ ] [M-3] <Accessibility, keyboard, and responsive checks>
- [ ] [M-4] <Edge cases with concrete inputs and outputs>

## Evidence Log
| ID | Command/Check | Result | Date | Notes |
|----|---------------|--------|------|-------|
| V-1 | `<command>` | pass/fail | YYYY-MM-DD | <output location or summary> |
| M-1 | <walkthrough> | pass | YYYY-MM-DD | <observation> |

## Deviations
- <Any criterion not fully met, why, and how it is tracked or resolved>

## Definition of Done (integration)
- [ ] Every automated and manual check executed, with evidence recorded
- [ ] Evidence traced to [R-n]; deviations documented
- [ ] Spec, code, roadmap, and changelog agree — merge as one coherent change
- [ ] Durable discoveries propagated to `tech-stack.md` / `mission.md`
````

Rules:

- Execute from this file; do not summarize from memory. "Tests pass" is not
  "validation complete" if the spec also requires a keyboard walkthrough or
  a real migration check.
- If a legitimate discovery changes the requirement, update requirements,
  plan, and validation **in the same branch as the code**, and note it
  here.
