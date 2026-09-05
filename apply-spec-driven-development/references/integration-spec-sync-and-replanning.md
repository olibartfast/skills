# Spec Sync and Replanning During Implementation

## Contents

- Why drift is the default
- Same-branch rule for spec/plan/code changes
- Classify each discovery
- Propagation matrix
- Integration gate
- Roadmap status and replanning after evidence
- Re-interview triggers
- Agent replaceability and handoff check

## Why drift is the default

The first implementation is guaranteed to be incomplete: hidden dependencies,
concurrency needs, API mismatches, and performance issues surface only when
executing. Drift between spec and reality is a *signal* about the problem, not
a defect of the process — provided you route it. The routing rule:

> If the spec was right, the code is wrong and changes. If the world turned out
> to differ from what the spec assumed, the spec changes — **in the same
> branch, with the revision and the reason made visible.**

Everything below exists to enforce that rule and to decide where each discovery
propagates.

## Same-branch rule for spec/plan/code changes

Discovered constraint or bug ⇒ update the affected spec, plan, and code in the
same branch and same change series:

- **Same branch**: a fix and its spec/plan updates land together. A branch
  whose spec diff is empty while its code contradicts the spec must not merge.
- **Same visibility**: list the pending spec or plan changes in every progress
  report alongside implementation status. "I'm updating the spec to say X"
  earns the same trust as "done with Y".
- **Reason recorded**: each spec/plan edit carries a note referencing the issue
  or discovery that caused it (e.g., "spec: retry limits are per-service, not
  global — found in phase 2", linking the failing test).

This differs from the anti-pattern of fixing docs at the end ("once done, sync
the docs"); end-of-project sync loses in-flight context and invites silent
drift. If the change was big enough, also record the broader lesson in the
retro so future specs start more accurate.

## Classify each discovery

When an execution gap is discovered (you can't proceed with the current plan,
or a current task failed), first classify it. A missing API parameter is very
different from "the fully-executed plan demonstrates the technical approach is
wrong".

| Type | Meaning | Typical action |
|---|---|---|
| **Implementation defect** | The spec/plan is fine; the executed code is wrong (bug, missed subtask, wrong file). | Fix the code; no spec or plan change. Optionally strengthen a validation criterion. |
| **Changed understanding** | Executing revealed how the system domain actually works; a requirement was incomplete or wrong, but the local fixed fix doesn't ripple project-wide. | Update the affected requirement and its spec sections in this branch; note the learning; continue per plan. |
| **Invalid assumption** | An input, interface, or environment behaved differently than the plan assumed (wrong API semantics, hidden dependency, unavailable platform). | Confirm by evidence, then update the *specific* assumption and the spec sections built on it; do not broaden conclusions project-wide. Local fix if narrow. |
| **Global decision** | The discovered implication is project-wide (e.g., the config system must handle concurrency, or the tech direction is wrong). Applies after the function is implemented, but the fix demands a project-level license. | Stop and escalate to the gate below. This is a decision about the project's future direction, not this branch's task — justify it project-wide with evidence. |

Practical habit: restate the discovery as a question — "is this about how the
code behaves (defect), what the system does (understanding), what the world is
like (assumption), or what the project should be (global)?" Misclassification
costs are asymmetric: treating a global issue as local fixes one call site and
leaves the rest broken; treating a local bug as global stalls the project in
debate.

## Propagation matrix

Given a discovery type, where must the change be recorded in the same branch?
R = required update, O = optional update, – = no change.

| Where ↘ / Type → | Implementation defect | Changed understanding | Invalid assumption | Global decision |
|---|---|---|---|---|
| **Requirements** | – | R (revise affected requirement) | R (revise the assumption-bearing requirement or record the confirmed assumption) | R (re-decision; justify project-wide) |
| **Spec / domain docs** | – | R (affected sections) | R (sections relying on the assumption) | R (section-level) |
| **Plan / tasks** | O (add a missing subtask) | O (adjust remaining tasks) | R (re-plan affected tasks) | R (re-plan roadmap-level tasks) |
| **Validation criteria** | O (close the gap that missed it) | R (what now counts as correct) | R (validate against reality, not assumption) | R |
| **Tech-stack doc** | – | – | R (if platform/library capability was the wrong assumption) | R (if switching direction) |
| **Code** | R (fix) | R (implement per revised spec) | R (implement per corrected assumption) | R (only after decision; may pause work) |
| **Roadmap** | – | O (if future items are affected) | O (if dependent roadmap items shift) | R (reorder, add, or strike items) |
| **Changelog** | O (user-visible fix) | O (behavioral change) | O (behavioral change) | R (project-level entry) |

Notes:

- "R" edits must be reviewable as part of the same change series; a reviewer
  should be able to trace code change ⇒ spec change ⇒ reason.
- For "changed understanding" and "invalid assumption", cite the evidence that
  forced the revision, per the provenance discipline (evidence over
  assumption) from the
[adoption reference](brownfield-adoption.md).
- Global decisions additionally may require a re-interview (see below) before
  the new requirements are written.

## Integration gate

At integration (merging a phase, feature, or branch back into the shared
baseline), verify before accepting:

1. **Consistency**: spec, plan, and code agree — no contradicting statements
   anywhere.
2. **Completeness**: all pending spec/plan updates from this branch were
   actually landed; the pending-updates list from progress reports is empty.
3. **Provenance**: remaining assumptions are labeled and either confirmed or
   explicitly accepted as risk.
4. **Validation**: all validation criteria pass, and late discoveries were
   reflected as strengthened criteria, not silently dropped.
5. **Scope debt**: temporary deviations (skipped validations, deferred edge
   cases) are recorded in the roadmap, not only in someone's memory.
6. **Handoff quality** (see the check below if the next executor is not the
   author).

Gate rule: a failed consistency or completeness item blocks the merge with a
required follow-up *in the same branch*, not a documentation ticket.

## Roadmap status and replanning after evidence

Keep the roadmap a live document with status language tied to evidence:

- `done` — implemented and validated (link evidence).
- `in progress` — an active feature packet exists in a branch.
- `planned` — requirements captured, no branch yet.
- `idea` — noted in inventory or retro; no requirements yet.
- `blocked` — with the blocking evidence and what would unblock it.
- `deferred` — deliberately postponed, with the reason it was moved and the
  condition (news that would change it, freed capacity, a dependency landing)
  under which to revisit it, listed in the roadmap's "Deferred / Revisit"
  section.

After a discovery with confirmed evidence (**changed understanding**,
**invalid assumption**, **global decision**), run a compact replanning pass:

1. Diff the roadmap: which items did this discovery make cheaper, more
   expensive, obsolete, or newly necessary?
2. Reorder by *new* information, not by the original plan's prestige. If the
   finding invalidated a technical-environment assumption, replan successor
   tasks that consumed that same assumption before anyone executes them.
3. Update plan-level dependencies between roadmap items (order and which module
   depends on which), then re-issue or amend affected feature packets.
4. Record the replanning decision and its evidence in the roadmap (one line
   per revision, dated).

Replanning is triggered by evidence, not by calendar: don't re-plan "monthly";
re-plan when a classification above (except pure implementation defect) lands.

## Re-interview triggers

Re-interview (the structured intent-names-and-constraints conversation that
produced the original requirements, possibly with the product/system owner or
with an agent driven by the same provenance labels) when any of these occurs:

- A **global decision** was classified and forms its basis project-wide.
- An **invalid assumption** invalidated a chain of more than one requirement.
- A **changed understanding** contradicts a requirement that was previously
  labeled `evidence` (meaning the confirming artifact itself was
  misinterpreted — go back to the source).
- The situation recurs: the same class of gap shows up in 2+ consecutive
  phases (a systemic misunderstanding).
- A new executor (agent or person) begins a high-assurance-tier item and
  reports the requirements ambiguous despite written provenance labels.

A re-interview is not a rewrite: confirm or revise only the opened questions,
bring fresh evidence back with provenance labels, and update the spec and
affected packets in the same branch as any resulting code change.

## Agent replaceability and handoff check

Any agent or contributor working on the project must be replaceable by the next
without loss. The executor at a session boundary is disposable; the project
state is not. Any hand-off to a different contributor or a fresh agent session
must be able to resume from documents alone.

Before closing a session or a branch, verify:

1. **Continuity artifact**: a session handoff exists — what was completed, in
   progress, pending, and the roadmap items opened as a result. Not "what I
   did" but "what state the project is in".
2. **Pending spec/plan updates** are committed or recorded on the branch, not
   in the executor's memory.
3. **Evidence linkage**: every non-obvious decision names its origin (issue,
   discovery, interview quote, measurement) — a stranger-completable audit
   trail.
4. **Discoveries classified**: each execution gap surfaced in the session has
   been classified (see above) and propagated per the matrix.
5. **Recall-specificity test**: a fresh executor (new agent session, new
   contributor) can pick the top roadmap item and start from documents alone —
   no verbal context required. If they cannot, the handoff gap is a defect to
   fix before the session counts as closed.

Because agents are inherently stateless between sessions, these written
invariants are what make convergence on project-wide quality possible at all.
A failed handoff check is treated as a global-decision-class discovery: record
what broke (which document was missing, which context was verbal), then fix the
workflow itself in the roadmap.
